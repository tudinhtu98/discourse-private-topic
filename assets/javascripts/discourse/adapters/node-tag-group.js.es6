import TagGroupAdapter from "admin/adapters/tag-group";
import { underscore } from "@ember/string";

const CUSTOME_TAG_TYPE = "node";

export default class VersionTagGroup extends TagGroupAdapter {
  pathFor(store, type, findArgs) {
    let path =
      this.basePath(store, type, findArgs) +
      underscore(
        store.pluralize(CUSTOME_TAG_TYPE + "_" + this.apiNameFor(type))
      );
    return this.appendQueryParams(path, findArgs);
  }

  apiNameFor() {
    return "tag_group";
  }
}
