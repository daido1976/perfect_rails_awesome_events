require 'rails_helper'

RSpec.describe EventsController, type: :request do
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

  describe 'GET #new' do
    context 'ログイン済みのユーザがアクセスした場合' do
      before { get '/auth/twitter/callback' }

      it 'イベント作成ページが表示されること' do
        get '/events/new'
        expect(response).to render_template('new')
      end
    end

    context '未ログインのユーザがアクセスした場合' do
      it 'トップページへリダイレクトされること' do
        get '/events/new'
        expect(response).to redirect_to root_path
      end

      it 'アラートが表示されること' do
        get '/events/new'
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'POST #create' do
    context 'ログイン済みのユーザが POST した場合' do
      before { get '/auth/twitter/callback' }

      context '正しい値が入力された場合' do
        let(:params) do
          {
            event: {
              name: 'event_name',
              place: 'event_place',
              content: 'event_content',
              start_time: rand(1..15).days.from_now,
              end_time: rand(15..30).days.from_now,
            },
          }
        end

        it 'イベントが新規作成されること' do
          expect { post '/events', params: params }.to change { Event.count }.by(1)
        end

        it 'events/:id にリダイレクトされること' do
          post '/events', params: params
          expect(response).to redirect_to("/events/#{Event.order(:created_at).last.id}")
        end
      end

      context '正しい値が入力されなかった場合' do
        # name が入力されていない
        let(:params) do
          {
            event: {
              name: '',
              place: 'event_place',
              content: 'event_content',
              start_time: rand(1..15).days.from_now,
              end_time: rand(15..30).days.from_now,
            },
          }
        end

        it 'イベントが作成されないこと' do
          expect { post '/events', params: params }.not_to change { Event.count }
        end

        it 'イベント作成ページが再度表示されること' do
          post '/events', params: params
          expect(response).to render_template('new')
        end

        it 'バリデーションエラーのアラートが表示されること' do
          post '/events', params: params
          expect(response.body).to include('名前を入力してください')
        end
      end
    end

    context '未ログインのユーザが POST した場合' do
      let(:params) do
        {
          event: {
            name: 'event_name',
            place: 'event_place',
            content: 'event_content',
            start_time: rand(1..15).hours.from_now,
            end_time: rand(15..30).hours.from_now,
          },
        }
      end

      it 'イベントが作成されないこと' do
        expect { post '/events', params: params }.not_to change { Event.count }
      end

      it 'トップページへリダイレクトされること' do
        post '/events', params: params
        expect(response).to redirect_to root_path
      end

      it 'アラートが表示されること' do
        post '/events', params: params
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'GET #show' do
    let!(:event) { create(:event) }

    context 'ログイン済みのユーザがアクセスした場合' do
      before { get '/auth/twitter/callback' }

      it 'イベント詳細ページが表示されること' do
        get "/events/#{event.id}"
        expect(response).to render_template('show')
      end
    end

    context '未ログインのユーザがアクセスした場合' do
      it 'イベント詳細ページが表示されること' do
        get "/events/#{event.id}"
        expect(response).to render_template('show')
      end
    end
  end

  describe 'GET #edit' do
    context 'ログイン済みのユーザがアクセスした場合' do
      before { get '/auth/twitter/callback' }

      context 'アクセスユーザが当該イベントのオーナーだった場合' do
        let!(:event) { create(:event, owner_id: User.order(:created_at).first.id) }

        it 'イベント編集ページが表示されること' do
          get "/events/#{event.id}/edit"
          expect(response).to render_template('edit')
        end
      end

      context 'アクセスユーザが当該イベントのオーナーでなかった場合' do
        let!(:event) { create(:event) }

        it 'error404 のページが表示されること' do
          get "/events/#{event.id}/edit"
          expect(response).to render_template('error404')
        end
      end
    end

    context '未ログインのユーザがアクセスした場合' do
      let!(:event) { create(:event) }

      it 'トップページへリダイレクトされること' do
        get "/events/#{event.id}/edit"
        expect(response).to redirect_to root_path
      end

      it 'アラートが表示されること' do
        get "/events/#{event.id}/edit"
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'PATCH #update' do
    context 'ログイン済みのユーザが PATCH した場合' do
      before { get '/auth/twitter/callback' }

      let!(:event) { create(:event, owner_id: User.order(:created_at).first.id, content: 'event_content') }

      context '正しい値が入力された場合' do
        let(:params) do
          {
            event: {
              name: 'event_name',
              place: 'event_place',
              content: 'updated_content',
              start_time: rand(1..15).hours.from_now,
              end_time: rand(15..30).hours.from_now,
            },
          }
        end

        it 'イベント情報が更新されること' do
          expect { patch "/events/#{event.id}", params: params }.to change { Event.find(event.id).content }.from('event_content').to('updated_content')
        end

        it 'events/:id にリダイレクトされること' do
          patch "/events/#{event.id}", params: params
          expect(response).to redirect_to("/events/#{event.id}")
        end
      end

      context '正しい値が入力されなかった場合' do
        # name が入力されていない
        let(:params) do
          {
            event: {
              name: '',
              place: 'event_place',
              content: 'updated_content',
              start_time: rand(1..15).days.from_now,
              end_time: rand(15..30).days.from_now,
            },
          }
        end

        it 'イベント情報が更新されないこと' do
          expect { patch "/events/#{event.id}", params: params }.not_to change { Event.find(event.id).content }
        end

        it 'イベント編集ページが再度表示されること' do
          patch "/events/#{event.id}", params: params
          expect(response).to render_template('edit')
        end

        it 'バリデーションエラーのアラートが表示されること' do
          patch "/events/#{event.id}", params: params
          expect(response.body).to include('名前を入力してください')
        end
      end
    end

    context '未ログインのユーザが PATCH した場合' do
      let!(:event) { create(:event, content: 'event_content') }

      let(:params) do
        {
          event: {
            name: 'event_name',
            place: 'event_place',
            content: 'updated_content',
            start_time: rand(1..15).hours.from_now,
            end_time: rand(15..30).hours.from_now,
          },
        }
      end

      it 'イベント情報が更新されないこと' do
        expect { patch "/events/#{event.id}", params: params }.not_to change { Event.find(event.id).content }
      end

      it 'トップページへリダイレクトされること' do
        patch "/events/#{event.id}", params: params
        expect(response).to redirect_to root_path
      end

      it 'アラートが表示されること' do
        patch "/events/#{event.id}", params: params
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'ログイン済みのユーザが DELETE した場合' do
      before { get '/auth/twitter/callback' }

      let!(:event) { create(:event, owner_id: User.order(:created_at).first.id) }

      it 'イベントを削除すること' do
        expect { delete "/events/#{event.id}" }.to change { Event.count }.by(-1)
      end

      it 'トップページへリダイレクトされること' do
        delete "/events/#{event.id}"
        expect(response).to redirect_to root_path
      end
    end

    context '未ログインのユーザが DELETE した場合' do
      let!(:event) { create(:event) }

      it 'イベントが削除されないこと' do
        expect { delete "/events/#{event.id}" }.not_to change { Event.count }
      end

      it 'トップページへリダイレクトされること' do
        delete "/events/#{event.id}"
        expect(response).to redirect_to root_path
      end

      it 'アラートが表示されること' do
        delete "/events/#{event.id}"
        expect(flash[:alert]).to be_present
      end
    end
  end
end
