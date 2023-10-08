export default function () {
  const customTagTypes = ["version", "node"];

  customTagTypes.forEach((customTagType) => {
    this.route(
      `${customTagType}Tags`,
      {
        path: `/${customTagType}_tags`,
        resetNamespace: true,
      },
      function () {
        this.route("index", { path: "/" });
      }
    );

    this.route(
      `${customTagType}TagGroups`,
      { path: `/${customTagType}_tag_groups`, resetNamespace: true },
      function () {
        this.route("edit", { path: "/:id" });
        this.route("new");
      }
    );
  });
}
