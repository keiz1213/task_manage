require 'rails_helper'

RSpec.describe 'Sessions' do
  let(:user) { create(:user) }
  let(:user_task) { create(:task, user: user) }

  describe '未ログイン状態でのアクセス' do
    describe 'タスク' do
      it 'タスク一覧にアクセスするとログインページにリダイレクトされる' do
        get tasks_path

        expect(is_logged_in?).to be_falsy
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_path
        expect(flash[:danger]).to eq 'ログインしてください'
      end
  
      it 'タスク詳細にアクセスするとログインページにリダイレクトされる' do
        get task_path user_task

        expect(is_logged_in?).to be_falsy
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_path
        expect(flash[:danger]).to eq 'ログインしてください'
      end

      it 'タスク編集にアクセスするとログインページにリダイレクトされる' do
        get edit_task_path user_task

        expect(is_logged_in?).to be_falsy
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_path
        expect(flash[:danger]).to eq 'ログインしてください'
      end

      it 'タスクを作成しようとするとログインページにリダイレクトされる' do
        post tasks_path

        expect(is_logged_in?).to be_falsy
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_path
        expect(flash[:danger]).to eq 'ログインしてください'
      end

      it 'タスクを更新しようとするとログインページにリダイレクトされる' do
        put task_path user_task

        expect(is_logged_in?).to be_falsy
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_path
        expect(flash[:danger]).to eq 'ログインしてください'
      end

      it 'タスクを削除しようとするとログインページにリダイレクトされる' do
        delete task_path user_task

        expect(is_logged_in?).to be_falsy
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_path
        expect(flash[:danger]).to eq 'ログインしてください'
      end
    end

    describe 'ユーザー管理' do
      it 'ユーザー一覧にアクセスするとログインページにリダイレクトされる' do
        get admin_users_path

        expect(is_logged_in?).to be_falsy
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_path
        expect(flash[:danger]).to eq 'ログインしてください'
      end

      it 'ユーザー詳細にアクセスするとログインページにリダイレクトされる' do
        get admin_user_path user

        expect(is_logged_in?).to be_falsy
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_path
        expect(flash[:danger]).to eq 'ログインしてください'
      end

      it 'ユーザー編集にアクセスするとログインページにリダイレクトされる' do
        get edit_admin_user_path user

        expect(is_logged_in?).to be_falsy
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_path
        expect(flash[:danger]).to eq 'ログインしてください'
      end

      it 'ユーザーを作成しようとするとログインページにリダイレクトされる' do
        post admin_users_path

        expect(is_logged_in?).to be_falsy
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_path
        expect(flash[:danger]).to eq 'ログインしてください'
      end

      it 'ユーザーを更新しようとするとログインページにリダイレクトされる' do
        put admin_user_path user

        expect(is_logged_in?).to be_falsy
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_path
        expect(flash[:danger]).to eq 'ログインしてください'
      end

      it 'ユーザーを削除しようとするとログインページにリダイレクトされる' do
        delete admin_user_path user

        expect(is_logged_in?).to be_falsy
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to login_path
        expect(flash[:danger]).to eq 'ログインしてください'
      end
    end
  end
end
