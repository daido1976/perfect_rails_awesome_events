require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#check_all_events_finished' do
    subject { user.destroy }

    let!(:user) { FactoryBot.create(:user) }

    context 'ユーザが公開中または参加予定の未終了イベントがない場合' do
      it 'ユーザが削除されること' do
        expect { subject }.to change { User.count }.by(-1)
      end
    end

    context 'ユーザが公開中の未終了イベントがある場合' do
      before { FactoryBot.create(:event, owner_id: user.id, start_time: Time.zone.now + 1.hour, end_time: Time.zone.now + 2.hours) }

      it 'ユーザが削除されないこと' do
        expect { subject }.not_to change { User.count }
      end

      it 'エラーメッセージが追加されること' do
        subject
        expect(user.errors[:base]).to include '公開中の未終了イベントが存在します。'
      end

      it 'false を返すこと' do
        expect(subject).to eq false
      end
    end

    context 'ユーザが参加予定の未終了イベントがある場合' do
      let(:event) { FactoryBot.create(:event, start_time: Time.zone.now + 1.hour, end_time: Time.zone.now + 2.hours) }

      before { FactoryBot.create(:ticket, user_id: user.id, event_id: event.id) }

      it 'ユーザが削除されないこと' do
        expect { subject }.not_to change { User.count }
      end

      it 'エラーメッセージが追加されること' do
        subject
        expect(user.errors[:base]).to include '参加予定の未終了イベントが存在します。'
      end

      it 'false を返すこと' do
        expect(subject).to eq false
      end
    end
  end
end
