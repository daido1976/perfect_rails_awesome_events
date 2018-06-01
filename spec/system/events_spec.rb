require 'rails_helper'

RSpec.describe 'Events', type: :system do
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

  context 'ログイン済みユーザの場合' do
    before { visit '/auth/twitter' }

    it 'イベント登録が完了すること' do
      # イベント登録画面にアクセスする
      visit 'events/new'

      # イベント詳細を入力して作成ボタンを押す
      fill_in 'event[name]', with: 'event_name'
      fill_in 'event[place]', with: 'event_place'
      select '2018', from: 'event[start_time(1i)]'
      select '7', from: 'event[start_time(2i)]'
      select '1', from: 'event[start_time(3i)]'
      select '12', from: 'event[start_time(4i)]'
      select '00', from: 'event[start_time(5i)]'
      select '2018', from: 'event[end_time(1i)]'
      select '7', from: 'event[end_time(2i)]'
      select '1', from: 'event[end_time(3i)]'
      select '13', from: 'event[end_time(4i)]'
      select '00', from: 'event[end_time(5i)]'
      fill_in 'event[content]', with: 'event_content'
      click_on '作成'
      expect(page).to have_content '作成しました'
      expect(page).to have_content 'event_name'
      expect(page).to have_content 'event_place'
      expect(page).to have_content '2018/07/01(日) 12:00'
      expect(page).to have_content '2018/07/01(日) 13:00'
      expect(page).to have_content 'event_content'
    end
  end

  context '未ログインユーザの場合' do
    it 'イベント登録画面にアクセスすると、トップページへリダイレクトされること' do
      visit 'events/new'
      expect(page).to have_content 'ログインしてください'
      expect(page).to have_content 'イベント一覧'
    end
  end
end
