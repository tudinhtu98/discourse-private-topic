class Tag
  scope :normal, -> { where(type_tag: self.name) }

  before_create :set_type_tag
  private

  def set_type_tag
    self.type_tag = self.class.name
  end

  def self.additional_filter_top_tags
    " AND tags.type_tag = '#{self.name}'" if column_names.include?('type_tag')
  end

  class << self
    alias_method :original_top_tags, :top_tags

    def top_tags(limit_arg: nil, category: nil, guardian: Guardian.new)
      core_top_tags(guardian: guardian)
    end
  end

  def self.core_top_tags(limit_arg: nil, category: nil, guardian: Guardian.new)
    # we add 1 to max_tags_in_filter_list to efficiently know we have more tags
    # than the limit. Frontend is responsible to enforce limit.
    limit = limit_arg || (SiteSetting.max_tags_in_filter_list + 1)
    scope_category_ids = guardian.allowed_category_ids
    scope_category_ids &= ([category.id] + category.subcategories.pluck(:id)) if category

    return [] if scope_category_ids.empty?

    filter_sql =
      (
        if guardian.is_staff?
          ""
        else
          " AND tags.id IN (#{DiscourseTagging.visible_tags(guardian).select(:id).to_sql})"
        end
      )

    # DIFF
    filter_sql = filter_sql + additional_filter_top_tags
    # ===================

    tag_names_with_counts = DB.query <<~SQL
      SELECT tags.name as tag_name, SUM(stats.topic_count) AS sum_topic_count
        FROM category_tag_stats stats
        JOIN tags ON stats.tag_id = tags.id AND stats.topic_count > 0
       WHERE stats.category_id in (#{scope_category_ids.join(",")})
       #{filter_sql}
    GROUP BY tags.name
    ORDER BY sum_topic_count DESC, tag_name ASC
       LIMIT #{limit}
    SQL

    tag_names_with_counts.map { |row| row.tag_name }
  end
end
