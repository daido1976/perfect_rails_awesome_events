require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe '#comment' do
    it { should allow_value(nil).for(:comment) }
    # 31文字の空文字を入力
    it { should allow_value(' ' * 31).for(:comment) }
    it { should validate_length_of(:comment).is_at_most(30) }
  end
end
