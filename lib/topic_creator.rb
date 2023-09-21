module InsertNewTypeOfTags
  def setup_tags(topic)
    if @opts[:node_tags].present?
      @opts[:node_tags].each do |node_tag|
        NodeTag.find_or_create_by(name: node_tag)
      end
      @opts[:tags] << @opts[:node_tags]
    end
    if @opts[:version_tags].present?
      @opts[:version_tags].each do |version_tag|
        VersionTag.find_or_create_by(name: version_tag)
      end
      @opts[:tags] << @opts[:version_tags]
    end
    
    super(topic)
  end
end

class TopicCreator
  prepend InsertNewTypeOfTags
end
