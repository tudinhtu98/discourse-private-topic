import { withPluginApi } from "discourse/lib/plugin-api";
import I18n from "I18n";
import { inject as service } from "@ember/service";
import getURL from "discourse-common/lib/get-url";
import TagSectionLink from "discourse/lib/sidebar/user/tags-section/tag-section-link";
import PMTagSectionLink from "discourse/lib/sidebar/user/tags-section/pm-tag-section-link";

export default {
  name: "version-tags-sidebar",
  initialize(container) {
    this.siteSettings = container.lookup("service:site-settings");

    withPluginApi("1.8.0", (api) => {
      api.addSidebarPanel(
        (BaseCustomSidebarPanel) =>
          class VersionTagsSidebarPanel extends BaseCustomSidebarPanel {
            key = "versionTags";
            switchButtonLabel = I18n.t("version_tagging.tags");
            switchButtonIcon = "list";
            switchButtonDefaultUrl = getURL("/version_tags");
          }
      );
    });

    withPluginApi("1.8.0", (api) => {
      api.addSidebarSection(
        (BaseCustomSidebarSection, BaseCustomSidebarSectionLink) => {
          const AllVersionTagsSectionLink = class extends BaseCustomSidebarSectionLink {
            constructor() {
              super(...arguments);
            }

            get name() {
              return "all_version_tag";
            }

            get route() {
              return "versionTags";
            }

            get title() {
              return I18n.t("version_tagging.all_tags");
            }

            get text() {
              return I18n.t("sidebar.all_tags");
            }

            get prefixType() {
              return "icon";
            }

            get prefixValue() {
              return "list";
            }
          };

          const VersionTagsSection = class extends BaseCustomSidebarSection {
            @service currentUser;
            @service router;
            @service site;
            @service siteSettings;
            @service topicTrackingState;

            constructor() {
              super(...arguments);

              if (container.isDestroyed) {
                return;
              }
              this.router = container.lookup("service:router");
            }

            get sectionLinks() {
              const links = [];

              let tags = this.site.top_version_tags || [];

              tags = tags.map((tag) => {
                return {
                  name: tag,
                  description: null,
                  pm_only: false,
                };
              });

              for (const tag of tags) {
                if (tag.pm_only) {
                  links.push(
                    new PMTagSectionLink({
                      tag,
                      currentUser: this.currentUser,
                    })
                  );
                } else {
                  links.push(
                    new TagSectionLink({
                      tag,
                      topicTrackingState: this.topicTrackingState,
                      currentUser: this.currentUser,
                    })
                  );
                }
              }

              links.push(new AllVersionTagsSectionLink());

              return links;
            }

            get name() {
              return "version-tags";
            }

            get title() {
              return I18n.t("version_tagging.tags");
            }

            get text() {
              return I18n.t("version_tagging.tags");
            }

            get actions() {
              return [
                {
                  id: "versionTags",
                  title: I18n.t("version_tagging.tags"),
                  action: () => this.router.transitionTo("versionTags.index"),
                },
              ];
            }

            get actionsIcon() {
              return "list";
            }

            get links() {
              return this.sectionLinks;
            }

            get displaySection() {
              return this.sectionLinks.length > 0;
            }
          };

          return VersionTagsSection;
        },
        "versionTags"
      );
    });
  },
};
