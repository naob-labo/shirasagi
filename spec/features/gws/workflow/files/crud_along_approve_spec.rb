require 'spec_helper'

describe "gws_workflow_files", type: :feature, dbscope: :example, tmpdir: true, js: true do
  context "crud along with approve path" do
    let(:site) { gws_site }
    let(:user) { gws_user }
    let(:index_path) { gws_workflow_files_path(site, state: 'all') }
    let!(:file) { tmp_ss_file(contents: '0123456789', user: user) }
    let(:item_name) { unique_id }
    let(:item_text) { unique_id }
    let(:item_name2) { unique_id }
    let(:item_text2) { unique_id }

    before { login_gws_user }

    it do
      visit index_path
      click_on I18n.t('gws/workflow.options.file_state.approve')

      #
      # Create
      #
      click_link I18n.t("ss.links.new")
      within "form#item-form" do
        fill_in "item[name]", with: item_name
        fill_in "item[text]", with: item_text

        click_on I18n.t("ss.buttons.upload")
      end

      within "article.file-view" do
        find("a.thumb").click
      end

      within "form#item-form" do
        submit_on I18n.t("ss.buttons.save")
      end

      within "#addon-basic" do
        expect(page).to have_content(item_name)
      end

      expect(Gws::Workflow::File.site(site).count).to eq 1
      item = Gws::Workflow::File.site(site).first
      expect(item.name).to eq item_name
      expect(item.text).to eq item_text
      expect(item.files.count).to eq 1
      expect(item.files.first.id).to eq file.id

      #
      # Update
      #
      click_on I18n.t("ss.links.edit")
      within "form#item-form" do
        fill_in "item[name]", with: item_name2
        fill_in "item[text]", with: item_text2
        click_on I18n.t("ss.buttons.save")
      end

      within "#addon-basic" do
        expect(page).to have_content(item_name2)
      end

      expect(Gws::Workflow::File.site(site).count).to eq 1
      item = Gws::Workflow::File.site(site).first
      expect(item.name).to eq item_name2
      expect(item.text).to eq item_text2
      expect(item.files.count).to eq 1
      expect(item.files.first.id).to eq file.id

      #
      # Soft Delete
      #
      click_on I18n.t("ss.links.delete")
      within "form" do
        click_on I18n.t("ss.buttons.delete")
      end
      expect(Gws::Workflow::File.site(site).count).to eq 1
      Gws::Workflow::File.site(site).first.tap do |workflow|
        expect(workflow.deleted).not_to be_nil
      end
    end
  end
end
