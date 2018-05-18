require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.find_or_create_from_auth_hash' do
    subject { User.find_or_create_from_auth_hash(auth_hash) }

    let(:auth_hash) do
      { provider: 'twitter', uid: '1234567890', info: { nickname: 'hogehoge', image: 'http://image.example.com' } }
    end

    context '引数(auth_hash)に関連するuserがDBに存在しない場合' do
      it 'userを新規作成すること' do
        expect { subject }.to change { User.all.count }.from(0).to(1)
      end
      it '引数(auth_hash)の内容でuserを作成すること' do
        expect(subject.provider).to eq 'twitter'
        expect(subject.uid).to eq '1234567890'
        expect(subject.nickname).to eq 'hogehoge'
        expect(subject.image_url).to eq 'http://image.example.com'
      end
    end

    context '引数(auth_hash)に関連するuserがすでにDBに存在する場合' do
      before { subject }

      it '同じuserを新規作成しないこと' do
        expect { subject }.not_to change { User.all.count }
      end
      it '引数(auth_hash)に関連するuserを返すこと' do
        expect(subject.provider).to eq 'twitter'
        expect(subject.uid).to eq '1234567890'
        expect(subject.nickname).to eq 'hogehoge'
        expect(subject.image_url).to eq 'http://image.example.com'
      end
    end
  end
end
