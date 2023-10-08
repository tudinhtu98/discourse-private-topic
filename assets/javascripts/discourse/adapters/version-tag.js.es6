import TagAdapter from "discourse/adapters/tag";

const CUSTOME_TAG_TYPE = "version";

export default TagAdapter.extend({
  pathFor(store, type, id) {
    return id ? `/${CUSTOME_TAG_TYPE}_tag/${id}` : `/${CUSTOME_TAG_TYPE}_tags`;
  },

  apiNameFor() {
    return "tag";
  },
});
