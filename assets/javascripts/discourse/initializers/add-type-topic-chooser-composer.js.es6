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
        isPrivateTopic: false,

        @discourseComputed("action")
        showPrivateTopicChooser(action) {
          return action === Composer.CREATE_TOPIC;
        },
      });

      // Add field is_private in ajax body with value of isPrivateTopic when create topic
      Composer.serializeOnCreate("is_private", "isPrivateTopic");
    });
  },
};
