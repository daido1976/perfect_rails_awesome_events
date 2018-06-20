require 'rails_helper'

RSpec.describe TicketsController, type: :request do
  let!(:user) do
    FactoryBot.create(
      :user,
      provider: 'twitter',
      uid: '1234567890',
      nickname: 'hogehoge',
      image_url: 'http://image.example.com',
    )
  end

  let!(:event) { FactoryBot.create(:event, owner_id: user.id) }

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

  describe 'POST #create' do
    context 'ログイン済みのユーザが POST した場合' do
      before { get '/auth/twitter/callback' }

      context '当該イベントに参加していない場合' do
        context 'イベント参加の modal で30文字以下のコメントがされた場合' do
          let(:params) { { ticket: { comment: 'example_comment' } } }

          it 'チケットが新規作成されること' do
            expect { post "/events/#{event.id}/tickets", params: params }.to change { Ticket.count }.by(1)
          end

          it 'HTTP ステータスコード 201 が返ること' do
            post "/events/#{event.id}/tickets", params: params
            expect(response.status).to eq 201
          end

          it 'フラッシュメッセージが表示されること' do
            post "/events/#{event.id}/tickets", params: params
            expect(flash[:notice]).to eq 'このイベントに参加表明しました'
          end
        end

        context 'イベント参加の modal で31文字以上のコメントがされた場合' do
          let(:params) { { ticket: { comment: 'a' * 31 } } }

          it 'チケットが新規作成されないこと' do
            expect { post "/events/#{event.id}/tickets", params: params }.not_to change { Ticket.count }
          end

          it 'HTTP ステータスコード 422 が返ること' do
            post "/events/#{event.id}/tickets", params: params
            expect(response.status).to eq 422
          end
        end
      end

      context '当該イベントに参加済みの場合' do
        let(:params) { { ticket: { comment: 'example_comment' } } }

        before { post "/events/#{event.id}/tickets", params: params }

        it '例外として ActiveRecord::RecordNotUnique が発生すること' do
          expect { post "/events/#{event.id}/tickets", params: params }.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end
    end

    context '未ログインのユーザが POST した場合' do
      let(:params) { { ticket: { comment: 'example_comment' } } }

      it 'チケットが新規作成されないこと' do
        expect { post "/events/#{event.id}/tickets", params: params }.not_to change { Ticket.count }
      end

      it 'トップページへリダイレクトされること' do
        post "/events/#{event.id}/tickets", params: params
        expect(response).to redirect_to root_path
      end

      it 'アラートが表示されること' do
        post "/events/#{event.id}/tickets", params: params
        expect(flash[:alert]).to eq 'ログインしてください'
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'ログイン済みのユーザが DELETE した場合' do
      before { get '/auth/twitter/callback' }

      context 'ユーザが当該チケットの作成者だった場合' do
        let!(:ticket) { FactoryBot.create(:ticket, user_id: user.id, event_id: event.id) }

        it 'チケットが削除されること' do
          expect { delete "/events/#{event.id}/tickets/#{ticket.id}" }.to change { Ticket.count }.by(-1)
        end

        it 'イベント詳細ページへリダイレクトされること' do
          delete "/events/#{event.id}/tickets/#{ticket.id}"
          expect(response).to redirect_to event
        end

        it 'アラートが表示されること' do
          delete "/events/#{event.id}/tickets/#{ticket.id}"
          expect(flash[:alert]).to eq 'このイベントの参加をキャンセルしました'
        end
      end

      context 'ユーザが当該チケットの作成者でなかった場合' do
        let!(:ticket) { FactoryBot.create(:ticket, event_id: event.id) }

        it 'チケットが削除されないこと' do
          expect { delete "/events/#{event.id}/tickets/#{ticket.id}" }.not_to change { Ticket.count }
        end

        it 'error404 のページが表示されること' do
          delete "/events/#{event.id}/tickets/#{ticket.id}"
          expect(response).to render_template('error404')
        end
      end
    end

    context '未ログインのユーザが DELETE した場合' do
      let!(:ticket) { FactoryBot.create(:ticket, user_id: user.id, event_id: event.id) }

      it 'チケットが削除されないこと' do
        expect { delete "/events/#{event.id}/tickets/#{ticket.id}" }.not_to change { Ticket.count }
      end

      it 'トップページへリダイレクトされること' do
        delete "/events/#{event.id}/tickets/#{ticket.id}"
        expect(response).to redirect_to root_path
      end

      it 'アラートが表示されること' do
        delete "/events/#{event.id}/tickets/#{ticket.id}"
        expect(flash[:alert]).to eq 'ログインしてください'
      end
    end
  end
end
