import MiniTagChooserComponent from "select-kit/components/mini-tag-chooser";
import I18n from "I18n";

const CUSTOME_TAG_TYPE = "version";

export default MiniTagChooserComponent.extend({
  search(filter) {
    const data = {
      q: filter || "",
      limit: this.maxTagSearchResults,
      categoryId: this.selectKit.options.categoryId,
    };

    if (this.value) {
      data.selected_tags = this.value.slice(0, 100);
    }

    if (!this.selectKit.options.everyTag) {
      data.filterForInput = true;
    }

    return this.searchTags(
      `/${CUSTOME_TAG_TYPE}_tags/filter/search`,
      data,
      this._transformJson
    );
  },

  modifyNoSelection() {
    if (this.selectKit.options.minimum > 0) {
      return this.defaultItem(
        null,
        I18n.t(`tagging.choose_for_${CUSTOME_TAG_TYPE}_required`, {
          count: this.selectKit.options.minimum,
        })
      );
    } else {
      return this.defaultItem(null, I18n.t(`tagging.choose_for_${CUSTOME_TAG_TYPE}`));
    }
  },
});
