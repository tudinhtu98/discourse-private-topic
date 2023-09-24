class VersionTagsController < TagsController
  def self.tag_klass
    VersionTag
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
end
