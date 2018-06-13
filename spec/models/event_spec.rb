require 'rails_helper'

RSpec.describe Event, type: :model do
  describe '#name' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(50) }
  end

  describe '#place' do
    it { should validate_presence_of(:place) }
    it { should validate_length_of(:place).is_at_most(100) }
  end

  describe '#content' do
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_most(2000) }
  end

  describe '#start_time' do
    it { should validate_presence_of(:start_time) }
  end

  describe '#end_time' do
    it { should validate_presence_of(:end_time) }
  end

  describe '#end_time_should_be_after_start_time' do
    context 'end_time が start_time より後の場合' do
      let(:valid_event) { FactoryBot.build(:event, start_time: Time.zone.now, end_time: Time.zone.now + 1.hour) }

      it 'event が有効であること' do
        expect(valid_event).to be_valid
      end
    end

    context 'end_time が start_time より前の場合' do
      let(:invalid_event) { FactoryBot.build(:event, start_time: Time.zone.now, end_time: Time.zone.now - 1.hour) }

      it 'event が無効であること' do
        expect(invalid_event).to be_invalid
      end
    end
  end

  describe '#created_by?' do
    subject { event.created_by?(user) }

    context 'イベントを作ったユーザである場合' do
      let(:user) { FactoryBot.create(:user) }
      let(:event) { FactoryBot.create(:event, owner_id: user.id) }

      it 'true を返す' do
        expect(subject).to eq true
      end
    end

    context 'イベントを作ったユーザでない場合' do
      let(:user) { FactoryBot.create(:user) }
      let(:event) { FactoryBot.create(:event) }

      it 'false を返す' do
        expect(subject).to eq false
      end
    end
  end
end
