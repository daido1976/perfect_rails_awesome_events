require 'rails_helper'

RSpec.describe 'Welcome', type: :request do
  describe 'GET #root' do
    before do
      create(:event)
      create(:event)
      create(:event, start_time: Time.zone.now - 1.hour)
      get '/'
    end

    it 'インデックスページが表示されること' do
      expect(response).to render_template 'index'
    end

    it '@events に未開催のイベント一覧が格納されていること' do
      expect(assigns(:events).count).to eq 2
    end
  end
end
