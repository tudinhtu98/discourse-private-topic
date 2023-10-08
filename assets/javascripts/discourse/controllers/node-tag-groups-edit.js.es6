import { inject as controller } from "@ember/controller";
import TagGroupsEditController from "discourse/controllers/tag-groups-edit";

const CUSTOME_TAG_TYPE = "node";

export default TagGroupsEditController.extend({
  tagGroups: controller(`${CUSTOME_TAG_TYPE}TagGroups`),

  actions: {
    onDestroy() {
      const tagGroups = this.tagGroups.model;
      tagGroups.removeObject(this.model);

      this.router.transitionTo(`${CUSTOME_TAG_TYPE}TagGroups.index`);
    },
  },
});
