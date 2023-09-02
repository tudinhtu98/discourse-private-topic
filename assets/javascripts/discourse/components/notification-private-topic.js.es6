import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";

export default Component.extend({
  bannerDismissed: false,

  @discourseComputed("topic", "bannerDismissed")
  showNotificationPromptBanner(topic, bannerDismissed) {
    return topic.is_private && !bannerDismissed;
  },

  actions: {
    publish() {
      this._super(...arguments);
      ajax(`/t/${this.topic.id}/change_visibility`, {
        type: "PUT",
        data: { is_private: false },
      }).then(() => {
        this.set("bannerDismissed", true);
      });
    },
    dismiss() {
      this.set("bannerDismissed", true);
    },
  },
});
