module DiscourseTagging
  class << self
    alias_method :org_filter_allowed_tags, :filter_allowed_tags
  end

  def self.filter_allowed_tags(guardian, opts = {})
    selected_tag_ids = opts[:selected_tags] ? Tag.where_name(opts[:selected_tags]).pluck(:id) : []
    category = opts[:category]
    category_has_restricted_tags =
      category ? (category.tags.count > 0 || category.tag_groups.count > 0) : false

    # If guardian is nil, it means the caller doesn't want tags to be filtered
    # based on guardian rules. Use the same rules as for staff users.
    filter_for_non_staff = !guardian.nil? && !guardian.is_staff?

    builder_params = {}

    builder_params[:selected_tag_ids] = selected_tag_ids unless selected_tag_ids.empty?

    sql = +"WITH #{TAG_GROUP_RESTRICTIONS_SQL}, #{CATEGORY_RESTRICTIONS_SQL}"
    if (opts[:for_input] || opts[:for_topic]) && filter_for_non_staff
      sql << ", #{PERMITTED_TAGS_SQL} "
      builder_params[:group_ids] = permitted_group_ids(guardian)
      sql.gsub!("/*and_group_ids*/", "AND group_id IN (:group_ids)")
    end

    outer_join = category.nil? || category.allow_global_tags || !category_has_restricted_tags

    topic_count_column = Tag.topic_count_column(guardian)

    distinct_clause =
      if opts[:order_popularity]
        "DISTINCT ON (#{topic_count_column}, name)"
      elsif opts[:order_search_results] && opts[:term].present?
        "DISTINCT ON (lower(name) = lower(:cleaned_term), #{topic_count_column}, name)"
      else
        ""
      end

    sql << <<~SQL
      SELECT #{distinct_clause} t.id, t.name, t.#{topic_count_column}, t.pm_topic_count, t.description,
        tgr.tgm_id as tgm_id, tgr.tag_group_id as tag_group_id, tgr.parent_tag_id as parent_tag_id,
        tgr.one_per_topic as one_per_topic, t.target_tag_id
      FROM tags t
      INNER JOIN tag_group_restrictions tgr ON tgr.tag_id = t.id
      #{outer_join ? "LEFT OUTER" : "INNER"}
        JOIN category_restrictions cr ON t.id = cr.tag_id
      /*where*/
      /*order_by*/
      /*limit*/
    SQL

    builder = DB.build(sql)

    # DIFF
    if opts[:type_tag]
      builder.where("type_tag = '#{opts[:type_tag]}'")
    else
      builder.where("type_tag = 'Tag'")
    end
    # ===================

    if !opts[:for_topic] && builder_params[:selected_tag_ids]
      builder.where("id NOT IN (:selected_tag_ids)")
    end

    if opts[:only_tag_names]
      builder.where("LOWER(name) IN (:only_tag_names)")
      builder_params[:only_tag_names] = opts[:only_tag_names].map(&:downcase)
    end

    # parent tag requirements
    if opts[:for_input]
      builder.where(
        (
          if builder_params[:selected_tag_ids]
            "tgm_id IS NULL OR parent_tag_id IS NULL OR parent_tag_id IN (:selected_tag_ids)"
          else
            "tgm_id IS NULL OR parent_tag_id IS NULL"
          end
        ),
      )
    end

    if category && category_has_restricted_tags
      builder.where(
        category.allow_global_tags ? "category_id = ? OR category_id IS NULL" : "category_id = ?",
        category.id,
      )
    elsif category || opts[:for_input] || opts[:for_topic]
      # tags not restricted to any categories
      builder.where("category_id IS NULL")
    end

    if filter_for_non_staff && (opts[:for_input] || opts[:for_topic])
      # exclude staff-only tag groups
      builder.where(
        "tag_group_id IS NULL OR tag_group_id IN (SELECT tag_group_id FROM permitted_tag_groups)",
      )
    end

    term = opts[:term]
    if term.present?
      term = term.gsub("_", "\\_").downcase
      builder_params[:cleaned_term] = term

      if opts[:term_type] == DiscourseTagging.term_types[:starts_with]
        builder_params[:term] = "#{term}%"
      else
        builder_params[:term] = "%#{term}%"
      end

      builder.where("LOWER(name) LIKE :term")
      sql.gsub!("/*and_name_like*/", "AND LOWER(t.name) LIKE :term")
    else
      sql.gsub!("/*and_name_like*/", "")
    end

    # show required tags for non-staff
    # or for staff when
    # - there are more available tags than the query limit
    # - and no search term has been included
    required_tag_ids = nil
    required_category_tag_group = nil
    if opts[:for_input] && category&.category_required_tag_groups.present? &&
          (filter_for_non_staff || term.blank?)
      category.category_required_tag_groups.each do |crtg|
        group_tags = crtg.tag_group.tags.pluck(:id)
        next if (group_tags & selected_tag_ids).size >= crtg.min_count
        if filter_for_non_staff || group_tags.size >= opts[:limit].to_i
          required_category_tag_group = crtg
          required_tag_ids = group_tags
          builder.where("id IN (?)", required_tag_ids)
        end
        break
      end
    end

    if filter_for_non_staff
      group_ids = permitted_group_ids(guardian)

      builder.where(<<~SQL, group_ids, group_ids)
        id NOT IN (
          (SELECT tgm.tag_id
            FROM tag_group_permissions tgp
            INNER JOIN tag_groups tg ON tgp.tag_group_id = tg.id
            INNER JOIN tag_group_memberships tgm ON tg.id = tgm.tag_group_id
            WHERE tgp.group_id NOT IN (?))

          EXCEPT

          (SELECT tgm.tag_id
            FROM tag_group_permissions tgp
            INNER JOIN tag_groups tg ON tgp.tag_group_id = tg.id
            INNER JOIN tag_group_memberships tgm ON tg.id = tgm.tag_group_id
            WHERE tgp.group_id IN (?))
        )
      SQL
    end

    if builder_params[:selected_tag_ids] && (opts[:for_input] || opts[:for_topic])
      one_tag_per_group_ids = DB.query(<<~SQL, builder_params[:selected_tag_ids]).map(&:id)
        SELECT DISTINCT(tg.id)
          FROM tag_groups tg
        INNER JOIN tag_group_memberships tgm ON tg.id = tgm.tag_group_id AND tgm.tag_id IN (?)
          WHERE tg.one_per_topic
      SQL

      if !one_tag_per_group_ids.empty?
        builder.where(
          "t.id NOT IN (SELECT DISTINCT tag_id FROM tag_group_restrictions WHERE tag_group_id IN (?)) OR id IN (:selected_tag_ids)",
          one_tag_per_group_ids,
        )
      end
    end

    builder.where("target_tag_id IS NULL") if opts[:exclude_synonyms]

    if opts[:exclude_has_synonyms]
      builder.where("id NOT IN (SELECT target_tag_id FROM tags WHERE target_tag_id IS NOT NULL)")
    end

    builder.where("name NOT IN (?)", opts[:excluded_tag_names]) if opts[:excluded_tag_names]&.any?

    if opts[:limit]
      if required_tag_ids && term.blank?
        # override limit so all required tags are shown by default
        builder.limit(required_tag_ids.size)
      else
        builder.limit(opts[:limit])
      end
    end

    if opts[:order_popularity]
      builder.order_by("#{topic_count_column} DESC, name")
    elsif opts[:order_search_results] && !term.blank?
      builder.order_by("lower(name) = lower(:cleaned_term) DESC, #{topic_count_column} DESC, name")
    end

    result = builder.query(builder_params).uniq { |t| t.id }

    if opts[:with_context]
      context = {}
      if required_category_tag_group
        context[:required_tag_group] = {
          name: required_category_tag_group.tag_group.name,
          min_count: required_category_tag_group.min_count,
        }
      end
      [result, context]
    else
      result
    end
  end
end
