require 'rails_helper'

RSpec.describe "Sessions" do
  let(:user) { create(:user) }

  describe 'ログイン' do
    context '有効なemailとpasswordの時' do
      it 'ログインできる' do
        visit login_path
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'ログイン'

        expect(page).to have_content('ログインしました')
        expect(page).to have_current_path(tasks_path)
      end
    end

    context '間違ったemailの時' do
      it 'ログインできない' do
        visit login_path
        fill_in 'Email', with: 'foo@example.com'
        fill_in 'Password', with: user.password
        click_button 'ログイン'

        expect(page).to have_content('パスワードまたはメールアドレスが間違っています')
        expect(page).to have_current_path(login_path)
      end
    end

    context '間違ったpasswordの時' do
      it 'ログインできない' do
        visit login_path
        fill_in 'Email', with: user.email
        fill_in 'Password', with: 'foo'
        click_button 'ログイン'

        expect(page).to have_content('パスワードまたはメールアドレスが間違っています')
        expect(page).to have_current_path(login_path)
      end
    end

    context '永続ログインを希望する時' do
      it 'cookieにuser_idとremember_tokenが保存されている' do
        visit login_path
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        check 'ログインしたままにする'
        click_button 'ログイン'

        expect(page).to have_content('ログインしました')
        expect(page).to have_current_path(tasks_path)
        expect(get_me_the_cookie('remember_token')).not_to be_nil
        expect(get_me_the_cookie('user_id')).not_to be_nil
      end
    end

    context '永続ログインを希望しない時' do
      it 'cookieにuser_idとremember_tokenが保存されていない' do
        visit login_path
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'ログイン'

        expect(page).to have_content('ログインしました')
        expect(page).to have_current_path(tasks_path)
        expect(get_me_the_cookie('remember_token')).to be_nil
        expect(get_me_the_cookie('user_id')).to be_nil
      end
    end
  end

  describe 'ログアウト' do
    it 'ログイン後、ログアウトできる' do
      visit login_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'ログイン'

      expect(page).to have_content('ログインしました')
      expect(page).to have_current_path(tasks_path)
      click_link 'ログアウト'
      expect(page).to have_content('ログアウトしました')
      expect(page).to have_current_path(login_path)
    end
  end
end
