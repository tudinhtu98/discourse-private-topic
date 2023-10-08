import TagGroupsEditRoute from "discourse/routes/tag-groups-edit";

const CUSTOME_TAG_TYPE = "version";

export default TagGroupsEditRoute.extend({
  model(params) {
    return this.store.find(`${CUSTOME_TAG_TYPE}TagGroup`, params.id);
  },
});
