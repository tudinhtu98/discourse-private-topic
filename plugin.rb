# name: discourse-private-topic
# about: Description for this plugin
# version: 1.0.2
# authors: Tu Dinh Tu
# url:

enabled_site_setting :discourse_private_topic_enabled

register_asset 'stylesheets/common.scss'

require_relative "lib/custom_tags/engine"

after_initialize do
  [
    '../app/controllers/topics_controller.rb',
    '../app/controllers/custom_tags/node_tags_controller.rb',
    '../app/controllers/custom_tags/version_tags_controller.rb',
    '../lib/post_reviser.rb',
    '../lib/topic_creator.rb',
    '../lib/discourse_tagging.rb',
    '../app/models/node_tag.rb',
    '../app/models/version_tag.rb',
    '../app/models/tag.rb',
    '../app/models/node_tag_group.rb',
    '../app/models/version_tag_group.rb',
    '../app/models/tag_group.rb',
    '../app/serializers/concern/topic_tags_mixin.rb',
    '../app/controllers/tags_controller.rb',
    '../lib/guardian/tag_guardian.rb',
    '../app/serializers/concern/site_permissions_mixin.rb',
    '../app/serializers/concern/preloaded_tags_mixin.rb',
    '../app/serializers/site_serializer.rb',
    '../app/controllers/custom_tags/node_tag_groups_controller.rb',
    '../app/controllers/tag_groups_controller.rb',
    '../app/controllers/custom_tags/version_tag_groups_controller.rb'
  ].each { |path| load File.expand_path(path, __FILE__) }

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

  module PrivateTopicsCreator
    def setup_topic_params
      topic_params = super
      topic_params[:is_private] = @opts[:is_private]
      topic_params
    end
  end

  module PrivateTopicsSuggestedOrdering
    def suggested_ordering(result, options)
      if !guardian&.user&.staff?
        super.where("topics.is_private=false")    
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

  class ::TopicCreator
    prepend PrivateTopicsCreator
  end

  class ::TopicQuery
    prepend PrivateTopicsSuggestedOrdering
  end

  TopicQuery.add_custom_filter(:private_topics) do |result, query|
    if SiteSetting.discourse_private_topic_enabled && !query&.guardian&.user&.staff?
      result = result.where(is_private: false).or(result.where(is_private: true, user_id: query&.guardian&.user&.id))
    end
    result
  end

  if SiteSetting.discourse_private_topic_enabled
    # this removes the categories from the "recent topics" shown on the 404 page
    # called from ApplicationController.build_not_found_page
    # this is cached without a user so just pass nil and exclude every private category
    class ::Topic
      module PrivateTopicsPatch404
        def recent(max = 10)
          if SiteSetting.discourse_private_topic_enabled
            Topic.listable_topics.visible.secured
              .where("(topics.is_private=false)")
              .order("created_at desc").limit(max)
          else
            super
          end
        end
      end
      singleton_class.prepend PrivateTopicsPatch404
    end

    class ::TopicTrackingState
      module PrivateTopicsListNew
        def new_filter_sql
          super + " AND topics.is_private=false"
        end
      end
      singleton_class.prepend PrivateTopicsListNew
    end

    add_permitted_post_create_param(:is_private)
    add_permitted_post_create_param(:node_tags, :array)
    add_permitted_post_create_param(:version_tags, :array)

    add_to_serializer(:topic_view, :is_private, false) {
      object.topic.is_private
    }
    add_to_serializer(:topic_view, :node_tags, false) {
      object.topic.tags.select { |tag| tag.type_tag=='NodeTag' }.map(&:name)
    }
    add_to_serializer(:topic_view, :version_tags, false) {
      object.topic.tags.select { |tag| tag.type_tag=='VersionTag' }.map(&:name)
    }
  end
end
