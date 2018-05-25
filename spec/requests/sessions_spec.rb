require 'rails_helper'

RSpec.describe SessionsController, type: :request do
  before do
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(
      provider: 'twitter',
      uid: '1234567890',
      info: {
        nickname: 'hogehoge',
        image: 'http://image.example.com',
      },
    )
  end

  describe '#create' do
    subject { get '/auth/twitter/callback' }

    context 'ユーザが未登録の場合' do
      it 'ユーザを新規作成すること' do
        get '/auth/twitter'
        expect { subject }.to change { User.count }.by(1)
      end

      it 'sessionにIDが保存されていること' do
        subject
        expect(session[:user_id]).to be_present
      end

      it 'ログイン後トップページにリダイレクトすること' do
        subject
        expect(response).to redirect_to root_path
      end
    end

    context 'ユーザが登録済みの場合' do
      before { create(:user, provider: 'twitter', uid: '1234567890') }

      it '新しいユーザが作成されないこと' do
        get '/auth/twitter'
        expect { subject }.not_to change { User.count }
      end

      it 'sessionにIDが保存されていること' do
        subject
        expect(session[:user_id]).to be_present
      end

      it 'ログイン後トップページにリダイレクトすること' do
        subject
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#destroy' do
    subject { get '/logout' }

    before { get '/auth/twitter/callback' }

    it 'sessionのIDが削除されていること' do
      subject
      expect(session[:user_id]).to be_nil
    end

    it 'ログアウト後トップページにリダイレクトすること' do
      subject
      expect(response).to redirect_to root_path
    end
  end
end
