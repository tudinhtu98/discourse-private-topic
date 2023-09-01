class TopicsController < ApplicationController
    def change_visibility
        raise Discourse::InvalidParameters.new(:topic_id) unless topic
        raise Discourse::InvalidAccess unless can_change_visibility?
        topic.update(is_private: params[:is_private])
        topic.save
        render json: success_json
    end

    private
    def can_change_visibility?
        guardian.is_staff? || topic.user_id == guardian.user&.try(:id)
    end

    def topic
        @topic ||= Topic.find_by(id: params[:topic_id])
    end
end
