# frozen_string_literal: true

class TagsController

  alias_method :org_index, :index
  alias_method :org_list, :list
  alias_method :org_search, :search
  class << self
    alias_method :org_tag_counts_json, :tag_counts_json
  end

  def self.tag_klass
    Tag.normal
  end

  def index
    core_index
  end

  def list
    core_list
  end

  def search
    core_search
  end

  def core_index
    @description_meta = I18n.t("tags.title")
    @title = @description_meta

    show_all_tags = guardian.can_admin_tags? && guardian.is_admin?

    if SiteSetting.tags_listed_by_group
      ungrouped_tags = self.class.tag_klass.where("tags.id NOT IN (SELECT tag_id FROM tag_group_memberships)")
      ungrouped_tags = ungrouped_tags.used_tags_in_regular_topics(guardian) unless show_all_tags
      ungrouped_tags = ungrouped_tags.order(:id)

      grouped_tag_counts =
        TagGroup
          .visible(guardian)
          .order("name ASC")
          .includes(:none_synonym_tags)
          .map do |tag_group|
            {
              id: tag_group.id,
              name: tag_group.name,
              tags: self.class.tag_counts_json(tag_group.none_synonym_tags, guardian),
            }
          end

      @tags = self.class.tag_counts_json(ungrouped_tags, guardian)
      @extras = { tag_groups: grouped_tag_counts }
    else
      tags = show_all_tags ? self.class.tag_klass.all : self.class.tag_klass.used_tags_in_regular_topics(guardian)
      tags = tags.order(:id)
      unrestricted_tags = DiscourseTagging.filter_visible(tags.where(target_tag_id: nil), guardian)

      categories =
        Category
          .where(
            "id IN (SELECT category_id FROM category_tags WHERE category_id IN (?))",
            guardian.allowed_category_ids,
          )
          .includes(:none_synonym_tags)
          .order(:id)

      category_tag_counts =
        categories
          .map do |c|
            category_tags =
              self.class.tag_counts_json(
                DiscourseTagging.filter_visible(c.none_synonym_tags, guardian),
                guardian,
              )

            next if category_tags.empty?

            { id: c.id, tags: category_tags }
          end
          .compact

      @tags = self.class.tag_counts_json(unrestricted_tags, guardian)
      @extras = { categories: category_tag_counts }
    end

    respond_to do |format|
      format.html { render :index }

      format.json { render json: { tags: @tags, extras: @extras } }
    end
  end

  def core_list
    offset = params[:offset].to_i || 0
    tags = guardian.can_admin_tags? ? self.class.tag_klass.all : self.class.tag_klass.visible(guardian)

    load_more_query_params = { offset: offset + 1 }

    if filter = params[:filter]
      tags = tags.where("LOWER(tags.name) ILIKE ?", "%#{filter.downcase}%")
      load_more_query_params[:filter] = filter
    end

    if only_tags = params[:only_tags]
      tags = tags.where("LOWER(tags.name) IN (?)", only_tags.split(",").map(&:downcase))
      load_more_query_params[:only_tags] = only_tags
    end

    if exclude_tags = params[:exclude_tags]
      tags = tags.where("LOWER(tags.name) NOT IN (?)", exclude_tags.split(",").map(&:downcase))
      load_more_query_params[:exclude_tags] = exclude_tags
    end

    tags_count = tags.count
    tags = tags.order("LOWER(tags.name) ASC").limit(LIST_LIMIT).offset(offset * LIST_LIMIT)

    load_more_url = URI("/tags/list.json")
    load_more_url.query = URI.encode_www_form(load_more_query_params)

    render_serialized(
      tags,
      TagSerializer,
      root: "list_tags",
      meta: {
        total_rows_list_tags: tags_count,
        load_more_list_tags: load_more_url.to_s,
      },
    )
  end

  def core_search
    filter_params = {
      for_input: params[:filterForInput],
      selected_tags: params[:selected_tags],
      exclude_synonyms: params[:excludeSynonyms],
      exclude_has_synonyms: params[:excludeHasSynonyms],
    }

    if limit = fetch_limit_from_params(default: nil, max: SiteSetting.max_tag_search_results)
      filter_params[:limit] = limit
    end

    filter_params[:category] = Category.find_by_id(params[:categoryId]) if params[:categoryId]

    if !params[:q].blank?
      clean_name = DiscourseTagging.clean_tag(params[:q])
      filter_params[:term] = clean_name
      filter_params[:order_search_results] = true
    else
      filter_params[:order_popularity] = true
    end

    tags_with_counts, filter_result_context =
      DiscourseTagging.filter_allowed_tags(guardian, **filter_params, with_context: true, type_tag: self.class.tag_klass.name)

    tags = self.class.tag_counts_json(tags_with_counts, guardian)

    json_response = { results: tags }

    if clean_name && !tags.find { |h| h[:id].downcase == clean_name.downcase } &&
         tag = self.class.tag_klass.where_name(clean_name).first
      # filter_allowed_tags determined that the tag entered is not allowed
      json_response[:forbidden] = params[:q]

      if filter_params[:exclude_synonyms] && tag.synonym?
        json_response[:forbidden_message] = I18n.t(
          "tags.forbidden.synonym",
          tag_name: tag.target_tag.name,
        )
      elsif filter_params[:exclude_has_synonyms] && tag.synonyms.exists?
        json_response[:forbidden_message] = I18n.t(
          "tags.forbidden.has_synonyms",
          tag_name: tag.name,
        )
      else
        category_names = tag.categories.where(id: guardian.allowed_category_ids).pluck(:name)
        category_names +=
          Category
            .joins(tag_groups: :tags)
            .where(id: guardian.allowed_category_ids, "tags.id": tag.id)
            .pluck(:name)

        if category_names.present?
          category_names.uniq!
          json_response[:forbidden_message] = I18n.t(
            "tags.forbidden.restricted_to",
            count: category_names.count,
            tag_name: tag.name,
            category_names: category_names.join(", "),
          )
        else
          json_response[:forbidden_message] = I18n.t(
            "tags.forbidden.in_this_category",
            tag_name: tag.name,
          )
        end
      end
    end

    if required_tag_group = filter_result_context[:required_tag_group]
      json_response[:required_tag_group] = required_tag_group
    end

    render json: json_response
  end

end
