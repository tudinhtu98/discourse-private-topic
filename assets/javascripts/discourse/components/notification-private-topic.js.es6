import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";

export default Component.extend({
  bannerDismissed: false,

  @discourseComputed("topic", "bannerDismissed")
  showNotificationPromptBanner(topic, bannerDismissed) {
    return topic && !bannerDismissed;
  },

  actions: {
    publish() {
      this._super(...arguments);
      ajax(`/t/${this.topic.id}/change_visibility`, {
        type: "PUT",
        data: { is_private: true },
      }).then((res) => {
        console.log(`Call /t/${this.topic.id}/change_visibility`);
        console.log("Published topic", res);
        this.set("bannerDismissed", true);
      });
    },
    dismiss() {
      this.set("bannerDismissed", true);
    },
  },
});
