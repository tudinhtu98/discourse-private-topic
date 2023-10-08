import I18n from "I18n";
import TagGroupsNewRoute from "discourse/routes/tag-groups-new";

const CUSTOME_TAG_TYPE = "version";

export default TagGroupsNewRoute.extend({
  beforeModel() {
    if (!this.siteSettings.tagging_enabled) {
      this.router.transitionTo(`${CUSTOME_TAG_TYPE}TagGroups`);
    }
  },

  model() {
    return this.store.createRecord(`${CUSTOME_TAG_TYPE}TagGroup`, {
      name: I18n.t("tagging.groups.new_name"),
    });
  },
});
