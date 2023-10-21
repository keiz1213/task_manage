require 'rails_helper'

RSpec.describe User do
  describe 'クラスメソッド' do
    describe 'digest' do
      it '文字列をハッシュ化する' do
        digest = described_class.digest('foo')
        expect(digest).to be_a BCrypt::Password
      end
    end

    describe 'new_token' do
      it 'ランダムな文字列を返す' do
        token = described_class.new_token
        expect(token).not_to be_nil
        expect(token).to be_a String
      end
    end
  end

  describe 'インスタンスメソッド' do
    describe 'remember' do
      it 'インスタンスのremember_digest属性が更新される' do
        user = create(:user)
        expect(user.remember_digest).to be_nil
        first_digest = user.remember
        expect(user.remember_digest).to eq first_digest
        second_digest = user.remember
        expect(user.remember_digest).to eq second_digest
      end
    end

    describe 'session_token' do
      context 'インスタンスにremember_digest属性が設定されている時' do
        it 'インスタンスのremember_digestの値を返す' do
          user = create(:user)
          remember_digest = user.remember
          expect(user.session_token).to eq remember_digest
        end
      end

      context 'インスタンスにremember_digest属性が設定されていない時' do
        it 'インスタンスにremember_digestを設定し、その値を返す' do
          user = create(:user)
          expect(user.remember_digest).to be_nil
          remember_digest = user.session_token
          expect(user.remember_digest).to eq remember_digest
        end
      end
    end

    describe 'authenticated?' do
      it 'remember_tokenの検証が成功するとtrueを返す' do
        user = create(:user)
        user.remember
        expect(user).to be_authenticated(user.remember_token)
      end

      it 'remember_tokenの検証が失敗するとfalseを返す' do
        user = create(:user)
        user.remember
        expect(user).not_to be_authenticated('foo')
      end
    end

    describe 'forget' do
      it 'インスタンスのremember_digest属性をnilに更新する' do
        user = create(:user)
        user.remember
        expect(user.remember_digest).not_to be_nil
        user.forget
        expect(user.remember_digest).to be_nil
      end
    end

    describe 'must_not_destroy_last_admin' do
      it '最後の管理者ユーザーは削除できない' do
        first_admin_user = create(:user)
        last_admin_user = create(:user)
        non_admin_user = create(:user, admin: false)
        expect(described_class.where(admin: true).count).to be 2

        first_admin_user.destroy
        last_admin_user.destroy
        non_admin_user.destroy

        expect(first_admin_user.errors).to be_empty
        expect(non_admin_user.errors).to be_empty
        expect(last_admin_user.errors).not_to be_empty
        expect(last_admin_user.errors.full_messages[0]).to eq '管理者ユーザーは最低一人必要です'
      end
    end
  end
end
