# frozen_string_literal: true

class NodeTagGroupsController < TagGroupsController
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

end
