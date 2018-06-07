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
    # 現在時刻を 2018/01/01 00:00 に固定する
    travel_to Time.zone.local(2018, 1, 1, 0o0, 0o0)
  end

  let(:event_id) { Event.last.id }

  describe 'イベント登録機能' do
    context 'ログイン済みユーザの場合' do
      before { visit '/auth/twitter' }

      it '登録が完了すること' do
        # イベント登録画面にアクセスする
        visit 'events/new'

        # イベント詳細を入力して作成ボタンを押す
        fill_in 'event[name]', with: 'event_name'
        fill_in 'event[place]', with: 'event_place'
        select '2018', from: 'event[start_time(1i)]'
        select '1', from: 'event[start_time(2i)]', match: :first
        select '1', from: 'event[start_time(3i)]'
        select '12', from: 'event[start_time(4i)]'
        select '00', from: 'event[start_time(5i)]'
        select '2018', from: 'event[end_time(1i)]'
        select '1', from: 'event[end_time(2i)]', match: :first
        select '1', from: 'event[end_time(3i)]'
        select '13', from: 'event[end_time(4i)]'
        select '00', from: 'event[end_time(5i)]'
        fill_in 'event[content]', with: 'event_content'
        click_on '作成'
        expect(page).to have_content '作成しました'
        expect(page).to have_content 'event_name'
        expect(page).to have_content 'event_place'
        expect(page).to have_content '2018/01/01(月) 12:00'
        expect(page).to have_content '2018/01/01(月) 13:00'
        expect(page).to have_content 'event_content'
      end
    end

    context '未ログインユーザの場合' do
      it '登録画面にアクセスすると、トップページへリダイレクトされること' do
        # イベント登録画面にアクセスする
        visit 'events/new'
        expect(page).to have_content 'ログインしてください'
        expect(page).to have_content 'イベント一覧'
      end
    end
  end

  describe 'イベント編集機能' do
    context 'ログイン済みユーザの場合' do
      before { visit '/auth/twitter' }

      context 'ユーザが当該イベントのオーナーだった場合' do
        before { create(:event, owner_id: User.last.id) }

        it '編集が完了すること' do
          # イベント詳細画面にアクセスする
          visit "events/#{event_id}"

          # イベント編集ボタンを押し、編集画面にアクセスする
          click_on 'イベントを編集する'

          # イベント詳細を入力して更新ボタンを押す
          fill_in 'event[name]', with: 'event_name'
          fill_in 'event[place]', with: 'event_place'
          select '2018', from: 'event[start_time(1i)]'
          select '1', from: 'event[start_time(2i)]', match: :first
          select '1', from: 'event[start_time(3i)]'
          select '12', from: 'event[start_time(4i)]'
          select '00', from: 'event[start_time(5i)]'
          select '2018', from: 'event[end_time(1i)]'
          select '1', from: 'event[end_time(2i)]', match: :first
          select '1', from: 'event[end_time(3i)]'
          select '13', from: 'event[end_time(4i)]'
          select '00', from: 'event[end_time(5i)]'
          fill_in 'event[content]', with: 'event_content'
          click_on '更新'
          expect(page).to have_content '更新しました'
          expect(page).to have_content 'event_name'
          expect(page).to have_content 'event_place'
          expect(page).to have_content '2018/01/01(月) 12:00'
          expect(page).to have_content '2018/01/01(月) 13:00'
          expect(page).to have_content 'event_content'
        end
      end

      context 'ユーザが当該イベントのオーナーでなかった場合' do
        before { create(:event) }

        it '編集画面にアクセスすると、error404 のページが表示されること' do
          # URL 上でパスを指定し、アクセスする
          visit "events/#{event_id}/edit"
          expect(page).to have_content 'ご指定になったページは存在しません'
        end
      end
    end

    context '未ログインユーザの場合' do
      before { create(:event) }

      it '編集画面にアクセスすると、トップページへリダイレクトされること' do
        # URL 上でパスを指定し、アクセスする
        visit "events/#{event_id}/edit"
        expect(page).to have_content 'ログインしてください'
        expect(page).to have_content 'イベント一覧'
      end
    end
  end

  describe 'イベント削除機能' do
    before do
      visit '/auth/twitter'
      create(:event, owner_id: User.last.id)
    end

    it 'イベント削除が完了すること' do
      # イベント詳細画面にアクセスする
      visit "events/#{event_id}"

      # イベント削除ボタンを押す
      click_on 'イベントを削除する'

      # confirm ダイアログのキャンセルを押す
      page.driver.browser.switch_to.alert.dismiss

      # イベント削除ボタンを押す
      click_on 'イベントを削除する'

      # confirm ダイアログのOKを押す
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content '削除しました'
    end
  end
end
