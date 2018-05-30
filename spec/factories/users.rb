FactoryBot.define do
  factory :user, aliases: [:owner] do
    provider 'twitter'
    uid '1234567890'
    nickname 'hogehoge'
    image_url 'http://image.example.com'
  end
end
