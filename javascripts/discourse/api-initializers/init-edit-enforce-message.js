import { apiInitializer } from "discourse/lib/api";
import EditEnforce from "../components/edit-enforce";

export default apiInitializer("1.15.0", (api) => {
  api.renderInOutlet("composer-action-after", EditEnforce);
});
