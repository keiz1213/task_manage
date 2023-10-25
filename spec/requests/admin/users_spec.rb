require 'rails_helper'

RSpec.describe "Admin::Users" do
  let(:admin_user) { create(:user) }
  let(:non_admin_user) { create(:user, admin: false) }

  it 'adminユーザーはユーザー管理ページにアクセスできる' do
    login_as(admin_user)
    get admin_users_path

    expect(response).to have_http_status(:ok)
  end

  it 'adminユーザー以外はユーザー管理ページにアクセスしようとすると404が返る' do
    login_as(non_admin_user)
    get admin_users_path

    expect(response).to have_http_status(:not_found)
    expect(response.body).to include 'お探しのページは見つかりませんでした'
  end

  it 'adminユーザー以外はユーザー詳細ページにアクセスしようとすると404が返る' do
    login_as(non_admin_user)
    get admin_user_path admin_user

    expect(response).to have_http_status(:not_found)
    expect(response.body).to include 'お探しのページは見つかりませんでした'
  end

  it 'adminユーザー以外はユーザーを作成しようとすると404が返る' do
    login_as(non_admin_user)
    post admin_users_path

    expect(response).to have_http_status(:not_found)
    expect(response.body).to include 'お探しのページは見つかりませんでした'
  end

  it 'adminユーザー以外はユーザーを更新しようとすると404が返る' do
    login_as(non_admin_user)
    put admin_user_path admin_user

    expect(response).to have_http_status(:not_found)
    expect(response.body).to include 'お探しのページは見つかりませんでした'
  end

  it 'adminユーザー以外はユーザーを削除しようとすると404が返る' do
    login_as(non_admin_user)
    delete admin_user_path admin_user

    expect(response).to have_http_status(:not_found)
    expect(response.body).to include 'お探しのページは見つかりませんでした'
  end
end
