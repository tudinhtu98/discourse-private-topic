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
end