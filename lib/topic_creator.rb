module InsertNewTypeOfTags
  def setup_tags(topic)
    if @opts[:node_tags].present?
      @opts[:node_tags].each do |node_tag|
        node_tag = NodeTag.find_by(name: node_tag)
        create_missing_node_tag(node_tag) if node_tag.nil?
      end
      @opts[:tags] << @opts[:node_tags]
    end
    if @opts[:version_tags].present?
      @opts[:version_tags].each do |version_tag|
        version_tag = VersionTag.find_by(name: version_tag)
        create_missing_version_tag(version_tag) if version_tag.nil?
      end
      @opts[:tags] << @opts[:version_tags]
    end
    
    super(topic)
  end

  def create_missing_node_tag(name)
    raise Discourse::InvalidAccess.new("You are not permitted to create node tag") unless @guardian.can_create_node_tag?
    NodeTag.create({name: name})
  end

  def create_missing_version_tag(name)
    raise Discourse::InvalidAccess.new("You are not permitted to create version tag") unless @guardian.can_create_version_tag?
    VersionTag.create({name: name})
  end
end

class TopicCreator
  prepend InsertNewTypeOfTags
end
