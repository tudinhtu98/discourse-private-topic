import EmberObject, { computed } from "@ember/object";
import { withPluginApi } from "discourse/lib/plugin-api";
import Composer from "discourse/models/composer";
import I18n from "I18n";

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

        showPrivateTopicChooser: computed(
          "action",
          "editingFirstPost",
          "user",
          function () {
            // return [Composer.CREATE_TOPIC, Composer.EDIT].includes(action);
            return (
              this.user.staff &&
              (this.action === Composer.CREATE_TOPIC ||
                (this.action === Composer.EDIT && this.editingFirstPost))
            );
          }
        ),

        cantSubmitPost: computed(
          "loading",
          "canEditTitle",
          "titleLength",
          "targetRecipients",
          "targetRecipientsArray",
          "replyLength",
          "categoryId",
          "missingReplyCharacters",
          "tags",
          "topicFirstPost",
          "minimumRequiredTags",
          "user.staff",
          "version_tags",
          function () {
            // can't submit while loading
            if (this.loading) {
              return true;
            }

            if (
              (this.action === Composer.CREATE_TOPIC ||
                this.action === Composer.EDIT) &&
              !this.version_tags.length > 0
            ) {
              return true;
            }

            // title is required when
            //  - creating a new topic/private message
            //  - editing the 1st post
            if (this.canEditTitle && !this.titleLengthValid) {
              return true;
            }

            // reply is always required
            if (this.missingReplyCharacters > 0) {
              return true;
            }

            if (
              this.site.can_tag_topics &&
              !this.isStaffUser &&
              this.topicFirstPost &&
              this.minimumRequiredTags
            ) {
              const tagsArray = this.tags || [];
              if (tagsArray.length < this.minimumRequiredTags) {
                return true;
              }
            }

            if (this.topicFirstPost) {
              // user should modify topic template
              const category = this.category;
              if (category && category.topic_template) {
                if (this.reply.trim() === category.topic_template.trim()) {
                  this.dialog.alert(
                    I18n.t("composer.error.topic_template_not_modified")
                  );
                  return true;
                }
              }
            }

            if (this.privateMessage) {
              // need at least one user when sending a PM
              return (
                this.targetRecipients && this.targetRecipientsArray.length === 0
              );
            } else {
              // has a category? (when needed)
              return this.requiredCategoryMissing;
            }
          }
        ),
      });

      // Reopen service composer
      api.modifyClass("service:composer", {
        versionTagValidation: computed(
          "model.version_tags",
          "lastValidatedAt",
          function () {
            if (!this.model.version_tags.length > 0) {
              return EmberObject.create({
                failed: true,
                reason: I18n.t("composer.error.version_tag_missing"),
                lastShownAt: this.lastValidatedAt,
              });
            }
          }
        ),
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
