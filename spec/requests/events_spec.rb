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

  describe '#new' do
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

  describe '#create' do
    subject { post '/events', params: event_params }

    before { get '/auth/twitter/callback' }

    context '正しい値が入力された場合' do
      let(:event_params) do
        { event: attributes_for(:event) }
      end

      it 'イベントが新規作成される' do
        expect { subject }.to change { Event.count }.by(1)
      end

      it 'events/:id にリダイレクトされること' do
        subject
        event_id = Event.last.id
        expect(response).to redirect_to("/events/#{event_id}")
      end
    end

    context '正しい値が入力されなかった場合' do
      let(:event_params) do
        { event: attributes_for(:event).merge(name: '') }
      end

      it 'イベントが作成されないこと' do
        expect { subject }.not_to change { Event.count }
      end

      it 'イベント作成ページが再度表示されること' do
        subject
        expect(response).to render_template('new')
      end
    end
  end
end
