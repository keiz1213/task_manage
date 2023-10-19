require 'rails_helper'

RSpec.describe 'Access restrictions' do
  let(:user) { create(:user) }
  let(:user_task) { create(:task, user: user) }
  let(:other_user) { create(:user) }
  let(:other_user_task) { create(:task, user: other_user) }

  describe '他者のタスクへのアクセス' do
    describe '他者のタスクの詳細を確認' do
      it '他者のタスクを表示しようとするとアクセス拒否されること' do
        login_as(user)
        get task_path other_user_task
        expect(response).to have_http_status(303)
        expect(response).to redirect_to tasks_path
      end
    end
  
    describe '他者のタスクを更新' do
      it '他者のタスクの編集ページにアクセスしようとするとアクセス拒否されること' do
        login_as(user)
        get edit_task_path other_user_task
        expect(response).to have_http_status(303)
        expect(response).to redirect_to tasks_path
      end
  
      it '他者のタスクを更新しようとするとアクセス拒否されること' do
        login_as(user)
        put task_path other_user_task
        expect(response).to have_http_status(303)
        expect(response).to redirect_to tasks_path
      end
    end
  
    describe '他者のタスクを削除' do
      it '他者のタスクを削除しようとするとアクセス拒否されること' do
        login_as(user)
        delete task_path other_user_task
        expect(response).to have_http_status(303)
        expect(response).to redirect_to tasks_path
      end
    end
  end

  describe '未ログイン状態でのアクセス' do
    it 'タスク一覧にアクセスするとログインページにリダイレクトされる' do
      get tasks_path
      expect(is_logged_in?).to be_falsy
      expect(response).to have_http_status(303)
      expect(response).to redirect_to login_path
      expect(flash[:danger]).to eq 'ログインしてください'
    end

    it 'タスク詳細にアクセスするとログインページにリダイレクトされる' do
      get task_path user_task
      expect(is_logged_in?).to be_falsy
      expect(response).to have_http_status(303)
      expect(response).to redirect_to login_path
      expect(flash[:danger]).to eq 'ログインしてください'
    end

    it 'タスク編集にアクセスするとログインページにリダイレクトされる' do
      get edit_task_path user_task
      expect(is_logged_in?).to be_falsy
      expect(response).to have_http_status(303)
      expect(response).to redirect_to login_path
      expect(flash[:danger]).to eq 'ログインしてください'
    end
  end
end
