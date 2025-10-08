import { apiInitializer } from "discourse/lib/api";
import EditEnforce from "../components/edit-enforce";

export default apiInitializer((api) => {
  api.renderInOutlet("composer-action-after", EditEnforce);
});
