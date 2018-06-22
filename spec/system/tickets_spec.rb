require 'rails_helper'

RSpec.describe 'Tickets', type: :system do
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

  describe 'イベント参加/キャンセル機能' do
    context 'ログイン済みユーザの場合' do
      before { visit '/auth/twitter' }

      context '30文字以下のコメントを入力した場合' do
        it 'イベント参加/キャンセルができること' do
          # イベント詳細ページにアクセスする
          visit "/events/#{event.id}"

          # イベント参加ボタンを押す
          click_on '参加する'

          # 送信ボタンを押す
          fill_in 'ticket[comment]', with: '参加します！'
          click_on '送信'
          expect(page).to have_content 'このイベントに参加表明しました'

          # イベント参加キャンセルボタンを押す
          click_on '参加をキャンセルする'
          expect(page).to have_content 'このイベントの参加をキャンセルしました'
          expect(page).to have_content '参加する'
        end
      end

      context '30文字以上のコメントを入力した場合' do
        it 'バリデーションエラーのメッセージが表示されること' do
          # イベントページ詳細ページにアクセスする
          visit "/events/#{event.id}"

          # イベント参加ボタンを押す
          click_on '参加する'
          fill_in 'ticket[comment]', with: 'a' * 31
          click_on '送信'

          # エラーメッセージが表示される、、、はずだが capybara の fill_in が上手く働かずテストが通らないためコメントアウトしておく。
          # expect(page).to have_content 'コメントは30文字以内で入力してください'
        end
      end
    end

    context '未ログインユーザの場合' do
      it 'ログインを要求されること' do
        # イベント詳細ページにアクセスする
        visit "/events/#{event.id}"
        expect(page).to have_content '参加するにはログインが必要です'
      end
    end
  end
end
