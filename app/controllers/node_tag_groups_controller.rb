# frozen_string_literal: true

class NodeTagGroupsController < TagGroupsController
  before_action :make_sure_tag_created, only: [:update, :create]
  def tag_group_klass
    NodeTagGroup
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

  def search
    core_search
  end

  def update
    super
  end

  def destroy
    super
  end

  private

  def fetch_tag_group
    core_fetch_tag_group
  end

  def make_sure_tag_created
    node_tags = []
    node_tags = node_tags.concat(params[:tag_names]) if params[:tag_names].present?
    node_tags = node_tags.concat(params[:parent_tag_name]) if params[:parent_tag_name].present?
    node_tags.each do |tag|
      NodeTag.find_or_create_by(name: tag)
    end
  end

end
