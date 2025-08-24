# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DevicesController, type: :controller do
  let(:api_key) { create(:api_key) }
  let(:user) { api_key.bearer }


  describe 'POST #assign' do
    subject(:assign) do
      post :assign,
           params: { new_owner_id: new_owner_id, device: { serial_number: '123456' } },
           session: { token: user.api_keys.first.token }
    end
    context 'when the user is authenticated' do
      context 'when user assigns a device to another user' do
        let(:new_owner_id) { create(:user).id }

        it 'returns an unauthorized response' do
          expect(response.code).to eq(422)
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Unauthorized' })
        end
      end

      context 'when user assigns a device to self' do
        let(:new_owner_id) { user.id }

        it 'returns a success response' do
          assign
          expect(response).to be_successful
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized response' do
        post :assign
        expect(response).to be_unauthorized
      end
    end
  end

  describe 'POST #unassign' do
    let(:serial_number) { '12345' }

    context 'when the user is authenticated' do
      let(:user) { create(:user) }

      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when user returns own device' do
        before do
          AssignDeviceToUser.new(
            requesting_user: user,
            serial_number: serial_number,
            new_device_owner_id: user.id
          ).call
        end

        it 'returns a success response' do
          post :unassign, params: { serial_number: serial_number, from_user: user.id }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when user tries to return a device assigned to another user' do
        let(:other_user) { create(:user) }

        before do
          AssignDeviceToUser.new(
            requesting_user: other_user,
            serial_number: serial_number,
            new_device_owner_id: other_user.id
          ).call
        end

        it 'returns an unprocessable entity response' do
          post :unassign, params: { serial_number: serial_number, from_user: user.id }
          expect(response).to be_unprocessable_entity
        end
      end

      context 'when device is not assigned' do
        it 'returns an unprocessable entity response' do
          post :unassign, params: { serial_number: serial_number, from_user: user.id }
          expect(response).to be_unprocessable_entity
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized response' do
        post :unassign, params: { serial_number: serial_number, from_user: 1 }
        expect(response).to be_unauthorized
      end
    end
  end
end
