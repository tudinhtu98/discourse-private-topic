import TagsIndexRoute from "discourse/routes/tags-index";
import I18n from "I18n";
import Tag from "discourse/models/tag";
import { action } from "@ember/object";

const CUSTOME_TAG_TYPE = "node";

export default TagsIndexRoute.extend({
  model() {
    return this.store.findAll(`${CUSTOME_TAG_TYPE}Tag`).then((result) => {
      if (result.extras) {
        if (result.extras.categories) {
          result.extras.categories.forEach((category) => {
            category.tags = category.tags.map((t) => Tag.create(t));
          });
        }
        if (result.extras.tag_groups) {
          result.extras.tag_groups.forEach((tagGroup) => {
            tagGroup.tags = tagGroup.tags.map((t) => Tag.create(t));
          });
        }
      }
      return result;
    });
  },

  titleToken() {
    return I18n.t(`${CUSTOME_TAG_TYPE}_tagging.tags`);
  },

  setupController(controller, model) {
    controller.setProperties({
      model,
      sortProperties: this.siteSettings.tags_sort_alphabetically
        ? ["id"]
        : ["totalCount:desc", "id"],
    });
  },

  @action
  showTagGroups() {
    this.router.transitionTo(`${CUSTOME_TAG_TYPE}TagGroups`);
    return true;
  },
});
