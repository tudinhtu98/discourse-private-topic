import { inject as controller } from "@ember/controller";
import TagGroupsNewController from "discourse/controllers/tag-groups-new";

const CUSTOME_TAG_TYPE = "node";

export default TagGroupsNewController.extend({
  tagGroups: controller(`${CUSTOME_TAG_TYPE}TagGroups`),

  actions: {
    onSave() {
      const tagGroups = this.tagGroups.model;
      tagGroups.pushObject(this.model);

      this.router.transitionTo(`${CUSTOME_TAG_TYPE}TagGroups.index`);
    },
  },
});
