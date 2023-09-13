import Component from "@ember/component";
import discourseComputed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";

export default Component.extend({
  bannerDismissed: false,

  init() {
    this._super(...arguments);

    // Listen event post-stream:refresh
    this.appEvents.on('post-stream:refresh', this, this.handlePostStreamRefresh);
  },

  @discourseComputed("topic", "bannerDismissed")
  showNotificationPromptBanner(topic, bannerDismissed) {
    return topic.is_private && !bannerDismissed;
  },

  willDestroyElement() {
    // Stop listen event post-stream:refresh
    this.appEvents.off('post-stream:refresh', this, this.handlePostStreamRefresh);

    this._super(...arguments);
  },

  handlePostStreamRefresh() {
    this.set("bannerDismissed", true);
    this.rerender();
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
