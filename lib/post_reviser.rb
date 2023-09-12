class PostRevisor
  track_topic_field(:is_private) do |topic_changes, attribute|
    track_and_revise topic_changes, :is_private, attribute
  end
end
