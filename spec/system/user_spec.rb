require 'rails_helper'

RSpec.describe 'Users', type: :system do
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

  describe 'ユーザ退会機能' do
    context 'ユーザが退会条件を満たしている場合' do
      context '自身が公開し、すでに終了したイベントがある場合' do
        let!(:event) { FactoryBot.create(:event, owner_id: user.id, start_time: Time.zone.now - 2.hours, end_time: Time.zone.now - 1.hour) }

        it 'ユーザが退会できること' do
          # ログインする
          visit '/'
          click_on 'Twitterでログイン'

          # 退会確認ページへアクセスする
          click_on '退会'
          expect(page).to have_content '退会の確認'

          # 退会ボタンを押す
          click_on '退会する'
          expect(page).to have_content '退会完了しました'

          # 自身が公開し、すでに終了したイベントの詳細ページへアクセスする
          visit "/events/#{event.id}"
          expect(page).to have_content '退会したユーザです'
        end
      end

      context '自身が参加し、すでに終了したイベントがある場合' do
        let!(:event) { FactoryBot.create(:event, start_time: Time.zone.now - 2.hours, end_time: Time.zone.now - 1.hour) }

        before { FactoryBot.create(:ticket, user_id: user.id, event_id: event.id) }

        it 'ユーザが退会できること' do
          # ログインする
          visit '/'
          click_on 'Twitterでログイン'

          # 退会確認ページへアクセスする
          click_on '退会'
          expect(page).to have_content '退会の確認'

          # 退会ボタンを押す
          click_on '退会する'
          expect(page).to have_content '退会完了しました'

          # 自身が参加し、すでに終了したイベントの詳細ページへアクセスする
          visit "/events/#{event.id}"
          expect(page).to have_content '退会したユーザです'
        end
      end
    end

    context 'ユーザが退会機能を満たしていない場合' do
      context '自身が公開中の未終了のイベントがある場合' do
        before { FactoryBot.create(:event, owner_id: user.id, start_time: Time.zone.now + 1.hour, end_time: Time.zone.now + 2.hours) }

        it 'ユーザが退会できないこと' do
          # ログインする
          visit '/'
          click_on 'Twitterでログイン'

          # 退会確認ページへアクセスする
          click_on '退会'
          expect(page).to have_content '退会の確認'

          # 退会ボタンを押す
          click_on '退会する'
          expect(page).to have_content '公開中の未終了イベントが存在します。'
        end
      end

      context '自身が参加予定の未終了のイベントがある場合' do
        let!(:event) { FactoryBot.create(:event, start_time: Time.zone.now + 1.hour, end_time: Time.zone.now + 2.hours) }

        before { FactoryBot.create(:ticket, user_id: user.id, event_id: event.id) }

        it 'ユーザが退会できないこと' do
          # ログインする
          visit '/'
          click_on 'Twitterでログイン'

          # 退会確認ページへアクセスする
          click_on '退会'
          expect(page).to have_content '退会の確認'

          # 退会ボタンを押す
          click_on '退会する'
          expect(page).to have_content '参加予定の未終了イベントが存在します。'
        end
      end
    end
  end
end
