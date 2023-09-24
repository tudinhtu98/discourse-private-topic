import { withPluginApi } from "discourse/lib/plugin-api";
import Composer from "discourse/models/composer";
import discourseComputed from "discourse-common/utils/decorators";

const PLUGIN_ID = "discourse-private-public-topic";

export default {
  name: "add-type-topic-chooser-composer",
  initialize() {
    withPluginApi("1.3.0", (api) => {
      api.modifyClass("model:composer", {
        pluginId: PLUGIN_ID,
        typeTopicOptions: [
          {
            id: false,
            name: "Public",
          },
          {
            id: true,
            name: "Private",
          },
        ],
        is_private: false,
        version_tags: [],
        node_tags: [],

        @discourseComputed("action", "editingFirstPost")
        showPrivateTopicChooser(action, editingFirstPost) {
          // return [Composer.CREATE_TOPIC, Composer.EDIT].includes(action);
          return (
            action === Composer.CREATE_TOPIC ||
            (action === Composer.EDIT && editingFirstPost)
          );
        },
      });

      // Add field is_private in ajax body with value of this.is_private when create topic
      Composer.serializeOnCreate("is_private", "is_private");
      Composer.serializeOnCreate("version_tags", "version_tags");
      Composer.serializeOnCreate("node_tags", "node_tags");

      // Add field is_private in ajax body with value of this.topic.is_private when edit topic
      Composer.serializeToTopic("is_private", "topic.is_private");
      Composer.serializeToTopic("version_tags", "topic.version_tags");
      Composer.serializeToTopic("node_tags", "topic.node_tags");
    });
  },
};
