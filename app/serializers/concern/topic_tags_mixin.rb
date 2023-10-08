# frozen_string_literal: true

module TopicTagsMixin
  alias_method :org_tags, :tags

  class << self
    alias_method :org_included, :included
  end

  def self.included(klass)
    klass.attributes :merged_tags
    klass.attributes :tags
    klass.attributes :node_tags
    klass.attributes :version_tags
    klass.attributes :tags_descriptions
  end

  def merged_tags
    all_tags
  end

  def tags
    all_tags.select { |tag| tag.type_tag=='Tag' }.map(&:name)
  end

  def node_tags
    all_tags.select { |tag| tag.type_tag=='NodeTag' }.map(&:name)
  end

  def version_tags
    all_tags.select { |tag| tag.type_tag=='VersionTag' }.map(&:name)
  end

end
