require 'rails_helper'

RSpec.describe UsersController, type: :request do
  let!(:user) do
    FactoryBot.create(
      :user,
      provider: 'twitter',
      uid: '1234567890',
      nickname: 'hogehoge',
      image_url: 'http://image.example.com',
    )
  end

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

  describe 'GET #retire' do
    context 'ログイン中の場合' do
      before { get '/auth/twitter/callback' }

      it '退会ページが表示されること' do
        get '/user/retire'
        expect(response).to render_template 'retire'
      end
    end

    context '未ログインの場合' do
      it 'トップページへリダイレクトされること' do
        get '/user/retire'
        expect(response).to redirect_to root_path
      end

      it 'アラートが表示されること' do
        get '/user/retire'
        expect(flash[:alert]).to eq 'ログインしてください'
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'ログイン中の場合' do
      before { get '/auth/twitter/callback' }

      context 'ユーザが退会条件を満たしている場合' do
        it 'ユーザが削除されること' do
          expect { delete '/user' }.to change { User.count }.by(-1)
        end

        it 'session の id が削除されること' do
          delete '/user'
          expect(session[:user_id]).to be_nil
        end

        it 'トップページへリダイレクトされること' do
          delete '/user'
          expect(response).to redirect_to root_path
        end

        it 'フラッシュメッセージが表示されること' do
          delete '/user'
          expect(flash[:notice]).to eq '退会完了しました'
        end
      end

      context 'ユーザが退会条件を満たしていない場合(公開中の未終了イベントが存在する)' do
        before { FactoryBot.create(:event, owner_id: user.id, start_time: Time.zone.now + 1.hour, end_time: Time.zone.now + 2.hours) }

        it 'ユーザが削除されないこと' do
          expect { delete '/user' }.not_to change { User.count }
        end

        it '退会ページが表示されること' do
          delete '/user'
          expect(response).to render_template 'retire'
        end

        it 'エラーメッセージが表示されること' do
          delete '/user'
          expect(response.body).to include '公開中の未終了イベントが存在します。'
        end
      end
    end

    context '未ログインの場合' do
      it 'ユーザが削除されないこと' do
        delete '/user'
        expect { subject }.not_to change { User.count }
      end

      it 'トップページへリダイレクトされること' do
        delete '/user'
        expect(response).to redirect_to root_path
      end

      it 'アラートメッセージが表示されること' do
        delete '/user'
        expect(flash[:alert]).to eq 'ログインしてください'
      end
    end
  end
end
