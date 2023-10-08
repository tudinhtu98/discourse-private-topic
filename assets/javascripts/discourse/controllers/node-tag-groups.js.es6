import TagGroupsController from "discourse/controllers/tag-groups";

const CUSTOME_TAG_TYPE = "node";

export default TagGroupsController.extend({
  actions: {
    newTagGroup() {
      this.router.transitionTo(`${CUSTOME_TAG_TYPE}TagGroups.new`);
    },
  },
});
