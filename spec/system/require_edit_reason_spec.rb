RSpec.describe "Require Edit Reason", type: :system do
  let!(:theme) { upload_theme_component }
  
  fab!(:admin)
  fab!(:user) { Fabricate(:user) }
  fab!(:group) { Fabricate(:group) }
  fab!(:edit_allowed_group) { Fabricate(:group) }
  fab!(:post) { Fabricate(:post, user: user, created_at: 1.hour.ago) }

  before do
    group.add(user)
    edit_allowed_group.add(user)
    SiteSetting.edit_post_allowed_groups = edit_allowed_group.id
    theme.update_setting(:edit_reason_required_groups, group.id)
    theme.update_setting(:edit_reason_grace_period, 5)
    theme.save!
    sign_in(user)
  end

  def force_edit_grace_period
    post.update!(updated_at: 10.minutes.ago)
  end

  def open_composer
    visit "/t/#{post.topic_id}"
    find(".post-action-menu__show-more").click
    find(".post-action-menu__edit").click
  end

  context "enforcement scenarios" do
    before do
      force_edit_grace_period
      open_composer
    end

    it "enforces edit reason when required" do
      expect(page).to have_css(".edit-enforcer")
      expect(page).to have_css(".save-or-cancel .create.disabled")
    end

    it "enables save with reason added" do
      fill_in "edit-reason", with: "Fixing typo"
      expect(page).to have_css(".edit-enforcer .d-icon-check")
      expect(page).to have_css(".save-or-cancel .create")
    end

    it "warns when no reason added" do
      find(".save-or-cancel .create.disabled").click
      
      expect(page).to have_css(".edit-enforcer.--highlight")
      expect(page).to have_css(".d-icon-triangle-exclamation")
      expect(page).to have_css(".save-or-cancel .create.disabled")
    end
  end

  context "grace period handling" do
    it "skips enforcement within grace period" do
      open_composer
      expect(page).to have_no_css(".edit-enforcer")
      expect(page).to have_no_css(".create.disabled")
    end
  end

  context "user permissions" do
    before { force_edit_grace_period }

    it "excludes non-group users" do
      group.remove(user)
      open_composer
      
      expect(page).to have_no_css(".edit-enforcer")
      expect(page).to have_css(".btn-primary:not(.disabled)")
    end

    it "excludes users not in required group" do
      admin.groups << edit_allowed_group  
      sign_in(admin)
      open_composer
      
      expect(page).to have_no_css(".edit-enforcer")
      expect(page).to have_css(".btn-primary:not(.disabled)")
    end
  end
end