FactoryBot.define do
  factory :ticket do
    user
    event
    comment 'ticket_comment'
  end
end
