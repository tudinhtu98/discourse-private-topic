class CustomTags::VersionTagsController < TagsController
  def self.tag_klass
    VersionTag
  end

  def tag_group_klass
    VersionTagGroup
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

  def upload
    core_upload
  end

  def list_unused
    core_list_unused
  end

  def destroy_unused
    core_destroy_unused
  end
end
