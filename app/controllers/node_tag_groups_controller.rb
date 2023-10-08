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
    params[:tag_names].concat(params[:parent_tag_name]).each do |tag|
      NodeTag.find_or_create_by(name: tag)
    end
  end

end
