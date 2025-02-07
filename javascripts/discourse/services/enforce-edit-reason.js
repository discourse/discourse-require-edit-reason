import { tracked } from "@glimmer/tracking";
import Service, { service } from "@ember/service";

export default class EnforceEditReason extends Service {
  @service currentUser;
  @service composer;
  @service siteSettings;

  @tracked enforceReason = false;

  toggleState(state) {
    this.composer.setProperties({
      disableSubmit: state,
      showEditReason: state,
    });
    this.enforceReason = state;
  }

  get composerModel() {
    return this.composer.model;
  }

  get isEditMode() {
    return this.composerModel?.action === "edit";
  }

  get isInGroup() {
    const groupSetting = new Set(
      settings.edit_reason_required_groups?.split("|").map(Number)
    );
    const userGroups = this.currentUser.groups || [];

    return userGroups.some((group) => groupSetting.has(group.id));
  }

  get outsideGracePeriod() {
    if (!settings.edit_reason_grace_period) {
      return true;
    }

    const post = this.composer.model.post;
    const now = Date.now();
    const gracePeriod = settings.edit_reason_grace_period * 1000;
    const lastEdit = new Date(post.updated_at);

    return now - lastEdit > gracePeriod;
  }

  get shouldEnforce() {
    return this.isInGroup && this.outsideGracePeriod && this.isEditMode;
  }
}
