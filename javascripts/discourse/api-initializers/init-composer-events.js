import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.15.0", (api) => {
  const editReasonService = api.container.lookup("service:enforce-edit-reason");

  api.onAppEvent("composer:open", () => {
    if (editReasonService.shouldEnforce) {
      editReasonService.toggleState(true);
    }
  });

  api.onAppEvent("composer:closed", () => {
    editReasonService.toggleState(false);
  });
});
