require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe '#comment' do
    it { should allow_value(nil).for(:comment) }
    # allow_nil ではなく、 allow_blank オプションを使用しているため、31文字以上の空文字を許容することを確認する
    it { should allow_value(' ' * 31).for(:comment) }
    it { should validate_length_of(:comment).is_at_most(30) }
  end
end
