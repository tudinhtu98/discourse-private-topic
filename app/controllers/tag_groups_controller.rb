# frozen_string_literal: true

class TagGroupsController
  def tag_group_klass
    TagGroup.normal
  end

  alias_method :org_index, :index
  alias_method :org_show, :show
  alias_method :org_new, :new
  alias_method :org_create, :create
  alias_method :org_search, :search
  alias_method :org_fetch_tag_group, :fetch_tag_group

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

  def core_index
    tag_groups = tag_group_klass.order("name ASC").includes(:parent_tag).preload(:tags).all
    serializer =
      ActiveModel::ArraySerializer.new(
        tag_groups,
        each_serializer: TagGroupSerializer,
        root: "tag_groups",
      )
    respond_to do |format|
      format.html do
        store_preloaded "tagGroups", MultiJson.dump(serializer)
        render "default/empty"
      end
      format.json { render_json_dump(serializer) }
    end
  end

  def core_show
    serializer = TagGroupSerializer.new(@tag_group)
    respond_to do |format|
      format.html do
        store_preloaded "tagGroup", MultiJson.dump(serializer)
        render "default/empty"
      end
      format.json { render_json_dump(serializer) }
    end
  end

  def core_new
    tag_groups = tag_group_klass.order("name ASC").includes(:parent_tag).preload(:tags).all
    serializer =
      ActiveModel::ArraySerializer.new(
        tag_groups,
        each_serializer: TagGroupSerializer,
        root: "tag_groups",
      )
    store_preloaded "tagGroup", MultiJson.dump(serializer)
    render "default/empty"
  end

  def core_create
    guardian.ensure_can_admin_tag_groups!
    @tag_group = tag_group_klass.new(tag_groups_params)
    if @tag_group.save
      render_serialized(@tag_group, TagGroupSerializer)
    else
      render_json_error(@tag_group)
    end
  end

  def core_search
    matches = tag_group_klass.includes(:tags).visible(guardian).all

    matches = matches.where("lower(name) ILIKE ?", "%#{params[:q].strip}%") if params[:q].present?

    if params[:names].present?
      matches = matches.where("lower(NAME) in (?)", params[:names].map(&:downcase))
    end

    matches =
      matches.order("name").limit(
        fetch_limit_from_params(default: 5, max: SiteSetting.max_tag_search_results),
      )

    render json: {
             results:
               matches.map { |x| { name: x.name, tag_names: x.tags.base_tags.pluck(:name).sort } },
           }
  end

  private

  def fetch_tag_group
    core_fetch_tag_group
  end

  def core_fetch_tag_group
    @tag_group = tag_group_klass.find(params[:id])
  end
end
