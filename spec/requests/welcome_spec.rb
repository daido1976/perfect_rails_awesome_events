require 'rails_helper'

RSpec.describe 'Welcome', type: :request do
  describe 'GET #root' do
    before do
      FactoryBot.create(:event)
      FactoryBot.create(:event)
      FactoryBot.create(:event, start_time: Time.zone.now - 1.hour)
      get '/'
    end

    it 'インデックスページが表示されること' do
      expect(response).to render_template 'index'
    end
  end
end
