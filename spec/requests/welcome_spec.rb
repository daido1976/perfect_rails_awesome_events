require 'rails_helper'

RSpec.describe 'Welcome', type: :request do
  describe 'GET #root' do
    it 'returns 200 OK' do
      get '/'
      expect(response.status).to eq 200
    end
  end
end
