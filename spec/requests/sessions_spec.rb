require 'rails_helper'

RSpec.describe SessionsController, type: :request do
  describe '#create' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(
        provider: 'twitter',
        uid: '12354567890',
        info: {
          nickname: 'hogehoge',
          image: 'http://image.example.com',
        },
      )
    end

    context 'ユーザがDBに存在していない場合' do
      it 'ユーザを新規作成すること' do
        get '/auth/twitter'
        expect { get '/auth/twitter/callback' }.to change { User.all.count }.by(1)
      end

      it 'sessionにIDが保存されていること' do
        get '/auth/twitter/callback'
        expect(session[:user_id]).to be_present
      end

      it 'ログイン後トップページにリダイレクトすること' do
        get '/auth/twitter/callback'
        expect(response).to redirect_to root_path
      end
    end

    context 'ユーザがDBにすでに存在している場合' do
      before { get '/auth/twitter/callback' }

      it '新しいユーザが作成されないこと' do
        get '/auth/twitter'
        expect { get '/auth/twitter/callback' }.not_to change { User.all.count }
      end

      it 'sessionにIDが保存されていること' do
        get '/auth/twitter/callback'
        expect(session[:user_id]).to be_present
      end
      
      it 'ログイン後トップページにリダイレクトすること' do
        get '/auth/twitter/callback'
        expect(response).to redirect_to root_path
      end
    end
  end
end
