import I18n from "I18n";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import showModal from "discourse/lib/show-modal";
import TagsIndexController from "discourse/controllers/tags-index";

const CUSTOME_TAG_TYPE = "node";

export default TagsIndexController.extend({
  actions: {
    showUploader() {
      showModal(`${CUSTOME_TAG_TYPE}-tag-upload`);
    },

    deleteUnused() {
      ajax(`/${CUSTOME_TAG_TYPE}_tags/unused`, { type: "GET" })
        .then((result) => {
          const displayN = 20;
          const tags = result["tags"];

          if (tags.length === 0) {
            this.dialog.alert(I18n.t("tagging.delete_no_unused_tags"));
            return;
          }

          const joinedTags = tags
            .slice(0, displayN)
            .join(I18n.t("tagging.tag_list_joiner"));
          const more = Math.max(0, tags.length - displayN);

          const tagsString =
            more === 0
              ? joinedTags
              : I18n.t("tagging.delete_unused_confirmation_more_tags", {
                  count: more,
                  tags: joinedTags,
                });

          const message = I18n.t("tagging.delete_unused_confirmation", {
            count: tags.length,
            tags: tagsString,
          });

          this.dialog.deleteConfirm({
            message,
            confirmButtonLabel: "tagging.delete_unused",
            didConfirm: () => {
              return ajax(`/${CUSTOME_TAG_TYPE}_tags/unused`, {
                type: "DELETE",
              })
                .then(() => this.send("triggerRefresh"))
                .catch(popupAjaxError);
            },
          });
        })
        .catch(popupAjaxError);
    },
  },
});
