require_relative 'tags/setup_new_tags'

class PostRevisor
  extend SetupNewTags

  track_topic_field(:is_private) do |topic_changes, attribute|
    track_and_revise topic_changes, :is_private, attribute
  end

  track_topic_field(:node_tags) do |tc, node_tags|
    node_tags = setup_node_tags(node_tags)
    tags = tc.topic.tags.map(&:name) + node_tags
    DiscourseTagging.tag_topic_by_names(tc.topic, tc.guardian, tags)
  end

  track_topic_field(:version_tags) do |tc, version_tags|
    version_tags = setup_version_tags(version_tags)
    tags = tc.topic.tags.map(&:name) + version_tags
    DiscourseTagging.tag_topic_by_names(tc.topic, tc.guardian, tags)
  end
end
