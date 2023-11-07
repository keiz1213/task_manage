require 'rails_helper'

RSpec.describe "Guest::Sessions" do
  it 'ゲストユーザーとしてログインできる' do
    create(:user, :guest_user)

    visit login_path
    click_link 'ゲストとしてログイン'

    expect(page).to have_content('ゲストとしてログインしました。自由にお使いください。')
    expect(page).to have_current_path(tasks_path)
  end
end
