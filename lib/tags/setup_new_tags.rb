# frozen_string_literal: true
module SetupNewTags
  def setup_node_tags(node_tags)
    node_tags = node_tags[0...SiteSetting.max_node_tags_per_topic]
    node_tags.each do |node_tag|
      item = NodeTag.find_by(name: node_tag)
      if item.nil?
        raise Discourse::InvalidAccess.new("You are not permitted to create node tag") unless @guardian.can_create_node_tag?
        NodeTag.create({name: node_tag})
      end
    end
    node_tags
  end

  def setup_version_tags(version_tags)
    version_tags = version_tags[0...SiteSetting.max_version_tags_per_topic]
    version_tags.each do |version_tag|
      item = VersionTag.find_by(name: version_tag)
      if item.nil?
        raise Discourse::InvalidAccess.new("You are not permitted to create version tag") unless @guardian.can_create_version_tag?
        VersionTag.create({name: version_tag})
      end
    end
    version_tags
  end

  def setup_tags(topic)
    if @opts[:tags].blank?
      @opts[:tags] = []
    end

    if @opts[:node_tags].present?
      @opts[:node_tags] = setup_node_tags(@opts[:node_tags])
      @opts[:tags] = @opts[:tags] + @opts[:node_tags]
    end
    if @opts[:version_tags].present?
      @opts[:version_tags] = setup_version_tags(@opts[:version_tags])
      @opts[:tags] = @opts[:tags] + @opts[:version_tags]
    end

    super(topic)
  end
end
