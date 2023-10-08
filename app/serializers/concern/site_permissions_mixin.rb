module SitePermissionsMixin
  def self.included(klass)
    klass.attributes :can_create_tag_node
    klass.attributes :can_create_tag_version
  end

  def can_create_tag_node
    scope.can_create_node_tag?
  end

  def can_create_tag_version
    scope.can_create_version_tag?
  end
end
