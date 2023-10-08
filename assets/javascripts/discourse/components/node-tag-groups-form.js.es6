import TagGroupsFormComponent from "discourse/components/tag-groups-form";
import PermissionType from "discourse/models/permission-type";
import I18n from "I18n";

const CUSTOME_TAG_TYPE = "node";

export default TagGroupsFormComponent.extend({
  actions: {
    save() {
      if (this.cannotSave) {
        this.dialog.alert(I18n.t("tagging.groups.cannot_save"));
        return false;
      }

      const attrs = this.buffered.getProperties(
        "name",
        "tag_names",
        "parent_tag_name",
        "one_per_topic",
        "permissions"
      );

      // If 'everyone' is set to full, we can remove any groups.
      if (
        !attrs.permissions ||
        attrs.permissions.everyone === PermissionType.FULL
      ) {
        attrs.permissions = { everyone: PermissionType.FULL };
      }

      this.model.save(attrs).then(() => {
        this.commitBuffer();

        if (this.onSave) {
          this.onSave();
        } else {
          this.router.transitionTo(`${CUSTOME_TAG_TYPE}TagGroups.index`);
        }
      });
    },
  },
});
