import { withPluginApi } from "discourse/lib/plugin-api";
import discourseComputed from "discourse-common/utils/decorators";

const PLUGIN_ID = "discourse-private-public-topic";

export default {
  name: "reopen-model-topic",
  initialize() {
    withPluginApi("1.3.0", (api) => {
      api.modifyClass("model:topic", {
        pluginId: PLUGIN_ID,

        @discourseComputed("version_tags", "node_tags", "tags")
        visibleListTags(versionTags, nodeTags, tags) {
          const newTags = [];

          if (
            !(versionTags || nodeTags || tags) ||
            !this.siteSettings.suppress_overlapping_tags_in_list
          ) {
            if (versionTags) {
              newTags.push(...versionTags);
            }

            if (nodeTags) {
              newTags.push(...nodeTags);
            }

            newTags.push(...tags);

            return newTags;
          }

          const title = this.title.toLowerCase();

          versionTags.forEach(function (tag) {
            if (!title.includes(tag.toLowerCase())) {
              newTags.push(tag);
            }
          });

          nodeTags.forEach(function (tag) {
            if (!title.includes(tag.toLowerCase())) {
              newTags.push(tag);
            }
          });

          tags.forEach(function (tag) {
            if (!title.includes(tag.toLowerCase())) {
              newTags.push(tag);
            }
          });

          return newTags;
        },
      });
    });
  },
};
