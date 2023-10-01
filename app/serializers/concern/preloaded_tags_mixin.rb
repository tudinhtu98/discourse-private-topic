module PreloadedTagsMixin
  def self.included(klass)
    klass.attributes :top_version_tags
    klass.attributes :top_node_tags
  end

  def top_version_tags
    @top_version_tags ||= VersionTag.top_tags(guardian: scope)
  end

  def top_node_tags
    @top_node_tags ||= NodeTag.top_tags(guardian: scope)
  end
end
