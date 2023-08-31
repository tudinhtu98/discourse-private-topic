import { withPluginApi } from "discourse/lib/plugin-api";

const PLUGIN_ID = "discourse-private-public-topic";

export default {
    name: "add-type-topic-chooser-composer",
    initialize() {
        withPluginApi("1.3.0", api => {
            api.modifyClass("model:composer", {
                pluginId: PLUGIN_ID,
                typeTopicOptions: [
                    {
                        id: 1,
                        name: "Public"
                    },
                    {
                        id: 2,
                        name: "Private"
                    }
                ],
                typeTopic: 1,
            });
        })
    }
}
