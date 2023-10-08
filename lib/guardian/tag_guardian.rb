module TagGuardian
  def can_create_node_tag?
    SiteSetting.tagging_enabled &&
      @user.has_trust_level_or_staff?(SiteSetting.min_trust_to_create_tag_node)
  end

  def can_create_version_tag?
    SiteSetting.tagging_enabled &&
      @user.has_trust_level_or_staff?(SiteSetting.min_trust_to_create_tag_version)
  end
end
