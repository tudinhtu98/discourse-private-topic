import TagsUploaderComponent from "admin/components/tags-uploader";

const CUSTOME_TAG_TYPE = "version";

export default class VersionTagsUploader extends TagsUploaderComponent.extend() {
  uploadUrl = `/${CUSTOME_TAG_TYPE}_tags/upload`;
}
