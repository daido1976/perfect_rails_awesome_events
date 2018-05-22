require 'rails_helper'

RSpec.describe SessionsController, type: :request do
  describe '#create' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
        provider: 'twitter',
        uid: '12354567890',
        info: {
          nickname: 'hogehoge',
          image: 'http://image.example.com'
        },
      })
    end

    it 'ユーザを新規作成すること' do
      get '/auth/twitter'
      expect { get '/auth/twitter/callback' }.to change { User.all.count }.from(0).to(1)
    end
  end
end
