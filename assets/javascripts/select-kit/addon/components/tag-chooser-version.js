import TagChooserComponent from "select-kit/components/tag-chooser";
import { makeArray } from "discourse-common/lib/helpers";

const CUSTOME_TAG_TYPE = "version";

export default TagChooserComponent.extend({
  search(query) {
    const selectedTags = makeArray(this.tags).filter(Boolean);

    const data = {
      q: query,
      limit: this.siteSettings.max_tag_search_results,
      categoryId: this.categoryId,
    };

    if (selectedTags.length || this.blockedTags.length) {
      data.selected_tags = selectedTags
        .concat(this.blockedTags)
        .uniq()
        .slice(0, 100);
    }

    if (!this.everyTag) {
      data.filterForInput = true;
    }
    if (this.excludeSynonyms) {
      data.excludeSynonyms = true;
    }
    if (this.excludeHasSynonyms) {
      data.excludeHasSynonyms = true;
    }

    return this.searchTags(
      `/${CUSTOME_TAG_TYPE}_tags/filter/search`,
      data,
      this._transformJson
    );
  },
});
