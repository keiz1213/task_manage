require 'rails_helper'

RSpec.describe 'Tasks' do
  let(:user) { create(:user) }
  let(:user_task) { create(:task, user: user) }
  let(:other_user) { create(:user) }
  let(:other_user_task) { create(:task, user: other_user) }

  describe '他者のタスクへのアクセス' do
    it '自身のタスクは表示できる' do
      login_as(user)
      get task_path user_task

      expect(response).not_to have_http_status(:not_found)
      expect(response.body).not_to include 'お探しのページは見つかりませんでした'
    end

    it '他者のタスクを表示しようとすると404が返される' do
      login_as(user)
      get task_path other_user_task

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include 'お探しのページは見つかりませんでした'
    end

    it '他者のタスクの編集ページにアクセスしようとすると404が返される' do
      login_as(user)
      get edit_task_path other_user_task

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include 'お探しのページは見つかりませんでした'
    end

    it '他者のタスクを更新しようとすると404が返される' do
      login_as(user)
      put task_path other_user_task

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include 'お探しのページは見つかりませんでした'
    end

    it '他者のタスクを削除しようとすると404が返される' do
      login_as(user)
      delete task_path other_user_task

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include 'お探しのページは見つかりませんでした'
    end
  end
end
