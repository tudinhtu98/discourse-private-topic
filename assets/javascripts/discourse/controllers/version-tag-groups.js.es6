import TagGroupsController from "discourse/controllers/tag-groups";

const CUSTOME_TAG_TYPE = "version";

export default TagGroupsController.extend({
  actions: {
    newTagGroup() {
      this.router.transitionTo(`${CUSTOME_TAG_TYPE}TagGroups.new`);
    },
  },
});
