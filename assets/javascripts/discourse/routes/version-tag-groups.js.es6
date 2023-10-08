import TagGroupsRoute from "discourse/routes/tag-groups";
import I18n from "I18n";

const CUSTOME_TAG_TYPE = "version";

export default TagGroupsRoute.extend({
  model() {
    const resultModel =  this.store.findAll(`${CUSTOME_TAG_TYPE}TagGroup`);
    return resultModel;
  },

  titleToken() {
    return I18n.t(`${CUSTOME_TAG_TYPE}_tagging.groups.title`);
  },
});
