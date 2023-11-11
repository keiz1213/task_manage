require 'rails_helper'

RSpec.describe "Admin::Users" do
  let(:admin_user) { create(:user) }

  describe 'ユーザーの管理ページ' do
    it 'ユーザーの管理ページが表示される' do
      login_as(admin_user)
      click_link 'ユーザー管理へ'

      expect(page).to have_content('Admin')
      expect(page).to have_content('タスク管理へ')
    end

    it '一般ユーザーでは管理者ページへのリンクが表示されない' do
      non_admin_user = create(:user, admin: false)
      login_as(non_admin_user)

      expect(page).not_to have_content('ユーザー管理へ')
    end
  end

  describe 'CRUD' do
    before do
      login_as(admin_user)
    end

    describe 'ユーザーの作成' do
      it '管理者はユーザーの作成ができる' do
        click_link 'ユーザー管理へ'
        click_link 'ユーザーを登録する'
        fill_in 'Name', with: 'test'
        fill_in 'Email', with: 'test@example.com'
        fill_in 'Password', with: 'password'
        fill_in 'Password confirmation', with: 'password'
        click_button '登録する'

        expect(page).to have_content('ユーザー: testを登録しました')
      end
    end

    describe 'ユーザーの一覧' do
      it '管理者はユーザーの一覧を確認できる' do
        user1 = create(:user, name: '中村')
        user2 = create(:user, name: '田中')
        create_list(:task, 3, user: user1)
        create_list(:task, 5, user: user2)
        click_link 'ユーザー管理へ'

        task_counts = all(:test, 'task-count')
        task_counts.each do |task_count|
          # 0はadmin_userの分
          expect(task_count.text).to match(/0|3|5/)
        end
        expect(page).to have_content('test-user')
        expect(page).to have_content('中村')
        expect(page).to have_content('田中')
      end
    end

    describe 'ユーザーの詳細' do
      it '管理者はユーザーの詳細を確認できる' do
        user = create(:user, name: '中村', admin: false)
        create_list(:task, 3, user: user)
        click_link 'ユーザー管理へ'
        click_link user.name
        task_titles = all(:test, 'task-title')

        expect(task_titles.count).to be 3
        expect(page).to have_content(user.name)
        expect(page).to have_content(user.email)
        expect(page).to have_content('一般')
        expect(page).to have_content(I18n.l(user.created_at, format: :long))
        expect(page).to have_content(I18n.l(user.updated_at, format: :long))
        expect(page).to have_content('編集')
        expect(page).to have_content('削除')
      end
    end

    describe 'ユーザーの更新' do
      it '管理者はユーザーをユーザー詳細画面から更新できる' do
        user = create(:user, name: '中村')
        click_link 'ユーザー管理へ'
        click_link user.name
        click_link '編集'
        fill_in 'Name', with: '中村2'
        fill_in 'Email', with: 'nakamura@example.com'
        fill_in 'Password', with: 'password'
        fill_in 'Password confirmation', with: 'password'
        click_button '更新する'

        expect(page).to have_content('ユーザー: 中村2を更新しました')
        expect(page).to have_content('中村2')
        expect(page).to have_content('nakamura@example.com')
      end

      it '管理者はユーザーをユーザー一覧画面から更新できる' do
        user = create(:user, name: '中村')
        click_link 'ユーザー管理へ'
        within "#user_#{user.id}" do
          click_link '編集'
        end
        fill_in 'Name', with: '中村2'
        fill_in 'Email', with: 'nakamura@example.com'
        fill_in 'Password', with: 'password'
        fill_in 'Password confirmation', with: 'password'
        click_button '更新する'

        expect(page).to have_content('ユーザー: 中村2を更新しました')
        expect(page).to have_content('中村2')
      end
    end

    describe 'ユーザーの削除' do
      it '管理者はユーザーをユーザー詳細画面から削除できる' do
        user = create(:user, name: '中村')
        click_link 'ユーザー管理へ'
        click_link user.name

        expect {
          accept_confirm do
            click_link '削除'
          end
          # TODO
          sleep(1)
        }.to change(User, :count).by(-1)
        expect(page).to have_content("ユーザー: #{user.name}を削除しました")
        expect(page).to have_current_path '/admin/users'
        expect(page).not_to have_link('中村')
      end

      it '管理者はユーザーをユーザー一覧画面から削除できる' do
        user = create(:user, name: '中村')
        click_link 'ユーザー管理へ'
        within "#user_#{user.id}" do
          expect {
            accept_confirm do
              click_link '削除'
            end
            # TODO
            sleep(1)
          }.to change(User, :count).by(-1)
        end
        expect(page).to have_content("ユーザー: #{user.name}を削除しました")
        expect(page).to have_current_path '/admin/users'
        expect(page).not_to have_link('中村')
      end

      it '最後の管理者は削除できない' do
        click_link 'ユーザー管理へ'
        click_link admin_user.name

        expect(User.where(admin: true).count).to be 1
        expect {
          accept_confirm do
            click_link '削除'
          end
          expect(page).to have_content("管理者ユーザーは最低一人必要です")
        }.not_to change(User, :count)
      end
    end
  end
end
