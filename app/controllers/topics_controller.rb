class TopicsController < ApplicationController
    def change_visibility
        topic = Topic.find_by(id: params[:topic_id])
        raise Discourse::InvalidParameters.new(:topic_id) unless topic
        raise Discourse::InvalidAccess unless can_change_visibility?(topic)
        topic.update(is_private: params[:is_private])
        topic.save
        render json: success_json
    end

    private
    def can_change_visibility?(topic)
        guardian.is_staff? || topic.user_id == guardian.user&.try(:id)
    end
end
