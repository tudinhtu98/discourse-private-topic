
CustomTags::Engine.routes.draw do
    scope "/node_tags" do
        get "/" => "node_tags#index"
        get "/filter/list" => "node_tags#index"
        get "/filter/search" => "node_tags#search"
        get "/list" => "node_tags#list"
        post "/upload" => "node_tags#upload"
        get "/unused" => "node_tags#list_unused"
        delete "/unused" => "node_tags#destroy_unused"
    end
    scope "/version_tags" do
        get "/" => "version_tags#index"
        get "/filter/list" => "version_tags#index"
        get "/filter/search" => "version_tags#search"
        get "/list" => "version_tags#list"
        post "/upload" => "version_tags#upload"
        get "/unused" => "version_tags#list_unused"
        delete "/unused" => "version_tags#destroy_unused"
    end
    resources :node_tag_groups, constraints: StaffConstraint.new, except: [:edit]
    resources :version_tag_groups, constraints: StaffConstraint.new, except: [:edit]
end

Discourse::Application.routes.draw { mount ::CustomTags::Engine, at: "" }

Discourse::Application.routes.append {
    put "t/:topic_id/change_visibility" => "topics#change_visibility", :constraints => { topic_id: /\d+/ }, defaults: { format: 'json' }
    get "all_tags/filter/search" => "tags#search_all_tags"
}