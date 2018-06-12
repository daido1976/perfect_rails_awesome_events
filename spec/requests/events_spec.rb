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

  let(:event_id) { Event.last.id }

  describe 'GET #new' do
    subject { get '/events/new' }

    context 'ログイン済みのユーザがアクセスした場合' do
      before { get '/auth/twitter/callback' }

      it 'イベント作成ページが表示されること' do
        subject
        expect(response).to render_template('new')
      end
    end

    context '未ログインのユーザがアクセスした場合' do
      it 'トップページへリダイレクトされること' do
        subject
        expect(response).to redirect_to root_path
      end

      it 'アラートが表示されること' do
        subject
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'POST #create' do
    subject { post '/events', params: event_params }

    context 'ログイン済みのユーザが POST した場合' do
      before { get '/auth/twitter/callback' }

      context '正しい値が入力された場合' do
        let(:event_params) { { event: attributes_for(:event) } }

        it 'イベントが新規作成されること' do
          expect { subject }.to change { Event.count }.by(1)
        end

        it 'events/:id にリダイレクトされること' do
          subject
          expect(response).to redirect_to("/events/#{event_id}")
        end
      end

      context '正しい値が入力されなかった場合' do
        let(:event_params) { { event: attributes_for(:event).merge(name: '') } }

        it 'イベントが作成されないこと' do
          expect { subject }.not_to change { Event.count }
        end

        it 'イベント作成ページが再度表示されること' do
          subject
          expect(response).to render_template('new')
        end
      end
    end

    context '未ログインのユーザが POST した場合' do
      let(:event_params) { { event: attributes_for(:event) } }

      it 'イベントが作成されないこと' do
        expect { subject }.not_to change { Event.count }
      end

      it 'トップページへリダイレクトされること' do
        subject
        expect(response).to redirect_to root_path
      end

      it 'アラートが表示されること' do
        subject
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'GET #show' do
    subject { get "/events/#{event_id}" }

    shared_examples 'イベント詳細ページが表示されること' do
      it do
        subject
        expect(response).to render_template('show')
      end
    end

    context 'ログイン済みのユーザがアクセスした場合' do
      before do
        get '/auth/twitter/callback'
        create(:event)
      end

      it_behaves_like 'イベント詳細ページが表示されること'
    end

    context '未ログインのユーザがアクセスした場合' do
      before do
        create(:event)
      end

      it_behaves_like 'イベント詳細ページが表示されること'
    end
  end

  describe 'GET #edit' do
    subject { get "/events/#{event_id}/edit" }

    context 'ログイン済みのユーザがアクセスした場合' do
      before { get '/auth/twitter/callback' }

      context 'アクセスユーザが当該イベントのオーナーだった場合' do
        before do
          create(:event, owner_id: User.last.id)
        end

        it 'イベント編集ページが表示されること' do
          subject
          expect(response).to render_template('edit')
        end
      end

      context 'アクセスユーザが当該イベントのオーナーでなかった場合' do
        before do
          create(:event)
        end

        it 'error404 のページが表示されること' do
          subject
          expect(response).to render_template('error404')
        end
      end
    end

    context '未ログインのユーザがアクセスした場合' do
      before do
        create(:event)
      end

      it 'トップページへリダイレクトされること' do
        subject
        expect(response).to redirect_to root_path
      end

      it 'アラートが表示されること' do
        subject
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'PATCH #update' do
    subject { patch "/events/#{event_id}", params: event_params }

    context 'ログイン済みのユーザが PATCH した場合' do
      before do
        get '/auth/twitter/callback'
        create(:event, owner_id: User.last.id, content: 'content')
      end

      context '正しい値が入力された場合' do
        let(:event_params) { { event: attributes_for(:event, content: 'updated_content') } }

        it 'イベント情報が更新されること' do
          expect { subject }.to change { Event.find(event_id).content }.from('content').to('updated_content')
        end

        it 'events/:id にリダイレクトされること' do
          subject
          expect(response).to redirect_to("/events/#{event_id}")
        end
      end

      context '正しい値が入力されなかった場合' do
        let(:event_params) { { event: attributes_for(:event, content: 'updated_content').merge(name: '') } }

        it 'イベント情報が更新されないこと' do
          expect { subject }.not_to change { Event.find(event_id).content }
        end

        it 'イベント編集ページが再度表示されること' do
          subject
          expect(response).to render_template('edit')
        end
      end
    end

    context '未ログインのユーザが PATCH した場合' do
      before { create(:event, content: 'content') }

      let(:event_params) { { event: attributes_for(:event, content: 'updated_content') } }

      it 'イベント情報が更新されないこと' do
        expect { subject }.not_to change { Event.find(event_id).content }
      end

      it 'トップページへリダイレクトされること' do
        subject
        expect(response).to redirect_to root_path
      end

      it 'アラートが表示されること' do
        subject
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'DELETE #destroy' do
    subject { delete "/events/#{event_id}" }

    context 'ログイン済みのユーザが DELETE した場合' do
      before do
        get '/auth/twitter/callback'
        create(:event, owner_id: User.last.id)
      end

      it 'イベントを削除すること' do
        expect { subject }.to change { Event.count }.by(-1)
      end

      it 'トップページへリダイレクトされること' do
        subject
        expect(response).to redirect_to root_path
      end
    end

    context '未ログインのユーザが DELETE した場合' do
      before { create(:event) }

      it 'イベントが削除されないこと' do
        expect { subject }.not_to change { Event.count }
      end

      it 'トップページへリダイレクトされること' do
        subject
        expect(response).to redirect_to root_path
      end

      it 'アラートが表示されること' do
        subject
        expect(flash[:alert]).to be_present
      end
    end
  end
end
