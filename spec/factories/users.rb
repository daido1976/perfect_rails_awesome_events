FactoryBot.define do
  factory :user, aliases: [:owner] do
    provider { 'twitter' }
    sequence(:uid) { |i| "uid_#{i}" }
    sequence(:nickname) { |i| "nickname_#{i}" }
    sequence(:image_url) { |i| "http://example.com/image_#{i}.jpg" }
  end
end
