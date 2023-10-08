import { withPluginApi } from "discourse/lib/plugin-api";
import { computed } from "@ember/object";

const PLUGIN_ID = "discourse-private-public-topic";

export default {
  name: "reopen-tag-drop",
  initialize() {
    withPluginApi("1.3.0", (api) => {
      api.modifyClass("component:tag-drop", {
        pluginId: PLUGIN_ID,

        topTags: computed(
          "currentCategory",
          "site.category_top_tags.[]",
          "site.top_version_tags.[]",
          "site.top_node_tags.[]",
          "site.top_tags.[]",
          function () {
            if (this.currentCategory && this.site.category_top_tags) {
              return this.site.category_top_tags || [];
            }

            return (
              [
                ...this.site.top_version_tags,
                ...this.site.top_node_tags,
                ...this.site.top_tags,
              ] || []
            );
          }
        ),

        search(filter) {
          if (filter) {
            const data = {
              q: filter,
              limit: this.maxTagSearchResults,
            };

            return this.searchTags(
              "/all_tags/filter/search",
              data,
              this._transformJson
            );
          } else {
            return (this.content || []).map((tag) => {
              if (tag.id && tag.name) {
                return tag;
              }
              return this.defaultItem(tag, tag);
            });
          }
        },
      });
    });
  },
};
