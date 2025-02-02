require 'spec_helper'

describe "category_nodes", type: :feature, dbscope: :example do
  let(:site) { cms_site }
  let(:node) { create :cms_node }
  let(:item) { create :category_node_node, filename: "#{node.filename}/name" }
  let(:index_path)  { category_nodes_path site.id, node }
  let(:new_path)    { "#{index_path}/new" }
  let(:show_path)   { "#{index_path}/#{item.id}" }
  let(:edit_path)   { "#{index_path}/#{item.id}/edit" }
  let(:delete_path) { "#{index_path}/#{item.id}/delete" }
  let(:split_path) { "#{index_path}/#{item.id}/split" }
  let(:integrate_path) { "#{index_path}/#{item.id}/integrate" }

  context "with auth" do
    before { login_cms_user }

    it "#index" do
      visit index_path
      expect(current_path).not_to eq sns_login_path
    end

    it "#new" do
      visit new_path
      within "form#item-form" do
        fill_in "item[name]", with: "sample"
        fill_in "item[basename]", with: "sample"
        click_button "保存"
      end
      expect(status_code).to eq 200
      expect(current_path).not_to eq new_path
      expect(page).to have_no_css("form#item-form")
    end

    it "#show" do
      visit show_path
      expect(status_code).to eq 200
      expect(current_path).not_to eq sns_login_path
    end

    it "#edit" do
      visit edit_path
      within "form#item-form" do
        fill_in "item[name]", with: "modify"
        click_button "保存"
      end
      expect(current_path).not_to eq sns_login_path
      expect(page).to have_no_css("form#item-form")
    end

    it "#delete" do
      visit delete_path
      within "form" do
        click_button "削除"
      end
      expect(current_path).to eq index_path
    end

    it "split" do
      visit split_path

      within "form" do
        fill_in "item[in_partial_name]", with: "modified"
        fill_in "item[in_partial_basename]", with: "basename"
        click_button I18n.t('ss.buttons.split')
      end

      expect(current_path).to eq show_path
    end

    it "#integrate" do
      visit integrate_path
    end
  end
end
