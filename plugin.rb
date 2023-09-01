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

    # hide topics from search results
    module PrivateTopicsPatchSearch
        def execute(readonly_mode: @readonly_mode)
            super

            if SiteSetting.discourse_private_topic_enabled && !@guardian&.user&.staff?
                @results.posts.delete_if do |post|
                    post&.topic&.is_private && (post&.topic&.user_id != @guardian&.user&.id)
                end
            end

            @results
        end
    end

    # hide topics on from post stream and raw
    module ::TopicGuardian
        alias_method :org_can_see_topic?, :can_see_topic?

        def can_see_topic?(topic, hide_deleted = true)
            allowed = org_can_see_topic?(topic, hide_deleted)
            return false unless allowed # false stays false

            if SiteSetting.discourse_private_topic_enabled && !@user&.staff?
                return false if topic&.is_private && (topic&.user_id != @user&.try(:id))
            end

            true
        end
    end

    # hide topics from user profile -> activity
    class ::UserAction
        module PrivateTopicsApplyCommonFilters
            def apply_common_filters(builder, user_id, guardian, ignore_private_messages=false)
                if SiteSetting.discourse_private_topic_enabled && !guardian&.user&.staff?
                    builder.where("(t.is_private=false OR (t.is_private=true AND t.user_id=#{guardian&.user&.id}))")
                end
                super(builder, user_id, guardian, ignore_private_messages)
            end
        end
        singleton_class.prepend PrivateTopicsApplyCommonFilters
    end

    # hide topics from user profile -> summary
    module PrivateTopicsPatchUserSummary
        def topics
            if SiteSetting.discourse_private_topic_enabled && !@guardian&.user&.staff?
                return super.where("(topics.is_private=false OR (topics.is_private=true AND topics.user_id=#{@guardian&.user&.id}))")
            end

            super
        end

        def replies
            if SiteSetting.discourse_private_topic_enabled && !@guardian&.user&.staff?
                return super.where("(topics.is_private=false OR (topics.is_private=true AND topics.user_id=#{@guardian&.user&.id}))")
            end

            super
        end

        def links
            if SiteSetting.discourse_private_topic_enabled && !@guardian&.user&.staff?
                return super.where("(topics.is_private=false OR (topics.is_private=true AND topics.user_id=#{@guardian&.user&.id}))")
            end

            super
        end
    end

    # this removes the categories from the "recent topics" shown on the 404 page
    # called from ApplicationController.build_not_found_page
    # this is cached without a user so just pass nil and exclude every private category
    class ::Topic
        def self.recent(max = 10)
            if SiteSetting.discourse_private_topic_enabled
                Topic.listable_topics.visible.secured
                    .where("(topics.is_private=false)")
                    .order("created_at desc").limit(max)
            else
                super
            end
        end
    end

    class ::Search
        prepend PrivateTopicsPatchSearch
    end

    class ::UserSummary
        prepend PrivateTopicsPatchUserSummary
    end

    TopicQuery.add_custom_filter(:private_topics) do |result, query|
        if SiteSetting.discourse_private_topic_enabled && !query&.guardian&.user&.staff?
            result = result.where(is_private: false).or(result.where(is_private: true, user_id: query&.guardian&.user&.id))
        end
        result
    end
end