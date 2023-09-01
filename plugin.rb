# name: discourse-private-topic
# about: Description for this plugin
# version: 0.1.0
# authors: Tu Dinh Tu
# url:

enabled_site_setting :discourse_private_topic_enabled

register_asset 'stylesheets/common.scss'

after_initialize do
    load File.expand_path('../app/controllers/discourse_private_topic_controller.rb', __FILE__)

    Discourse::Application.routes.append do
        # Map the path `/name` to `DiscoursePPTController`’s `index` method
        # Remove route if not in use
        # get '/name' => 'discourse_private_topic#index'
    end

    TopicQuery.add_custom_filter(:private_topics) do |result, query|
        if SiteSetting.discourse_private_topic_enabled && !query&.guardian&.user&.staff?
            result = result.where(is_private: false).or(result.where(is_private: true, user_id: query&.guardian&.user&.id))
        end
        result
    end
end