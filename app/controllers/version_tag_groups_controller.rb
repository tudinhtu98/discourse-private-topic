# frozen_string_literal: true

class VersionTagGroupsController < TagGroupsController
  before_action :make_sure_tag_created, only: [:update, :create]
  def tag_group_klass
    VersionTagGroup
  end

  def index
    core_index
  end

  def show
    core_show
  end

  def new
    core_new
  end

  def create
    core_create
  end

  def update
    super
  end

  def destroy
    super
  end

  def search
    core_search
  end

  private

  def fetch_tag_group
    core_fetch_tag_group
  end

  def make_sure_tag_created
    tags = []
    data = params[:tag_group]
    tags.concat(data[:tag_names]) if data[:tag_names].present?
    tags.concat(data[:parent_tag_name]) if data[:parent_tag_name].present?
    existed_tags = VersionTag.where(name: tags).pluck(:name)
    missing_tags = tags - existed_tags
    missing_node_tag_objs = missing_tags.map do |tag_name|
      { name: tag_name, type_tag: 'VersionTag' }
    end
    VersionTag.insert_all(missing_node_tag_objs) if missing_node_tag_objs.present?
  end

end
