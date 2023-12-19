# frozen_string_literal: true

module ::CustomTags
  class Engine < ::Rails::Engine
    engine_name "custom_tags"
    isolate_namespace CustomTags
  end
end
