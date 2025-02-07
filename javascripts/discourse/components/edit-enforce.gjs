import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";
import { not } from "truth-helpers";

export default class EditEnforce extends Component {
  @service enforceEditReason;
  @service composer;

  @tracked hasEditReason = false;
  @tracked getAttention = false;
  @tracked highlight = false;

  inputHandler = () => {
    if (this.inputElement?.value.trim()) {
      this.editReasonElement?.classList.remove("--danger");
      this.composer.set("disableSubmit", false);
      this.hasEditReason = true;
      this.getAttention = false;
      this.highlight = false;
    } else {
      this.hasEditReason = false;
      this.highlight = true;
      this.composer.set("disableSubmit", true);
    }
  };

  attentionHandler = () => {
    this.getAttention = true;
    this.highlight = true;

    setTimeout(() => {
      this.getAttention = false;
    }, 500);
  };

  get editReasonElement() {
    return document.querySelector(".display-edit-reason");
  }

  get inputElement() {
    return document.getElementById("edit-reason");
  }

  get createButtonElement() {
    return document.querySelector(".create.disabled");
  }

  get shouldShow() {
    return this.enforceEditReason.enforceReason;
  }

  @action
  setupListeners() {
    this.inputElement?.addEventListener("input", this.inputHandler);
    this.createButtonElement?.addEventListener(
      "pointerdown",
      this.attentionHandler
    );
  }

  @action
  cleanupListeners() {
    this.inputElement?.removeEventListener("input", this.inputHandler);
    this.createButtonElement?.removeEventListener(
      "pointerdown",
      this.attentionHandler
    );
  }

  @action
  resetState() {
    this.enforceEditReason.toggleState(false);
  }

  <template>
    {{#if this.shouldShow}}
      <div
        class="edit-enforcer
          {{unless this.hasEditReason '--danger'}}
          {{if this.getAttention '--animate'}}
          {{if this.highlight '--highlight'}}"
        {{didInsert this.setupListeners}}
        {{willDestroy this.cleanupListeners}}
        {{didUpdate
          this.resetState
          this.enforceEditReason.composerModel.action
        }}
      >
        {{#if (not this.hasEditReason)}}
          {{icon "triangle-exclamation"}}
          {{i18n "form_kit.errors.required"}}
        {{else}}
          {{icon "check"}}
        {{/if}}
      </div>
    {{/if}}
  </template>
}
