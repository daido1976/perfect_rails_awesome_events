require 'rails_helper'

RSpec.describe 'Welcome', type: :system do
  before do
    create(:event, name: 'future_event_1')
    create(:event, name: 'future_event_2')
    create(:event, name: 'past_event', start_time: Time.zone.now - 1.hour)
  end

  it 'トップページに未開催のイベント一覧が表示されること' do
    visit '/'
    expect(page).to have_content 'future_event_1'
    expect(page).to have_content 'future_event_2'
    expect(page).not_to have_content 'past_event'
  end
end
