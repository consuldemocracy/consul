require 'rails_helper'

describe "Admin custom content blocks" do

  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  it "Index" do
    block = create(:site_customization_content_block)
    visit admin_site_customization_content_blocks_path

    expect(page).to have_content(block.name)
    expect(page).to have_content(block.body)
  end

  context "Create" do
    it "Valid custom block" do
      visit admin_root_path

      within("#side_menu") do
        click_link "Custom content blocks"
      end

      expect(page).to_not have_content "footer (es)"

      click_link "Create new content block"

      select "footer", from: "site_customization_content_block_name"
      select "es", from: "site_customization_content_block_locale"
      fill_in "site_customization_content_block_body", with: "Some custom content"

      click_button "Create Custom content block"

      expect(page).to have_content "footer (es)"
      expect(page).to have_content "Some custom content"
    end

    it "Invalid custom block" do
      block = create(:site_customization_content_block)

      visit admin_root_path

      within("#side_menu") do
        click_link "Custom content blocks"
      end

      expect(page).to have_content "top_links (en)"

      click_link "Create new content block"

      select "top_links", from: "site_customization_content_block_name"
      select "en", from: "site_customization_content_block_locale"
      fill_in "site_customization_content_block_body", with: "Some custom content"

      click_button "Create Custom content block"

      expect(page).to have_content "Content block couldn't be created"
      expect(page).to have_content "has already been taken"
    end
  end

  context "Update" do
    it "Valid custom block" do
      block = create(:site_customization_content_block)
      visit admin_root_path

      within("#side_menu") do
        click_link "Custom content blocks"
      end

      click_link "top_links (en)"

      fill_in "site_customization_content_block_body", with: "Some other custom content"
      click_button "Update Custom content block"

      expect(page).to have_content "Content block updated successfully"
      expect(page).to have_content "Some other custom content"
    end
  end

  context "Delete" do
    it "From index page" do
      block = create(:site_customization_content_block)
      visit   admin_site_customization_content_blocks_path

      expect(page).to have_content("#{block.name} (#{block.locale})")
      expect(page).to have_content(block.body)

      click_button "Delete block"

      expect(page).to_not have_content("#{block.name} (#{block.locale})")
      expect(page).to_not have_content(block.body)
    end

    it "From edit page" do
      block = create(:site_customization_content_block)
      visit edit_admin_site_customization_content_block_path(block)

      click_button "Delete block"

      expect(page).to_not have_content("#{block.name} (#{block.locale})")
      expect(page).to_not have_content(block.body)
    end
  end
end
