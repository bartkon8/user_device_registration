# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReturnDeviceFromUser do
  let(:serial_number) { '12345' }
  let(:user) { create(:user) }

  subject(:perform) do
    -> {
      described_class.new(
        user: user,
        serial_number: serial_number,
        from_user: user.id
      ).call
    }
  end

  context 'when returning own assigned device' do
    before do
      AssignDeviceToUser.new(
        requesting_user: user,
        serial_number: serial_number,
        new_device_owner_id: user.id
      ).call
    end

    it 'sets returned_at and succeeds' do
      expect { perform.call }.not_to raise_error

      device = Device.find_by(serial_number: serial_number)
      assignment = DeviceAssignment.find_by(device: device, user_id: user.id)

      expect(assignment).to be_present
      expect(assignment.returned_at).to be_present

      if device.respond_to?(:current_owner_id)
        expect(device.reload.current_owner_id).to be_nil
      end
    end
  end

  context 'when device does not exist' do
    it 'raises DeviceNotFound' do
      expect { perform.call }.to raise_error(AssigningError::DeviceNotFound)
    end
  end

  context 'when device exists but is not assigned' do
    before { Device.create!(serial_number: serial_number) }

    it 'raises NotAssigned' do
      expect { perform.call }.to raise_error(AssigningError::NotAssigned)
    end
  end

  context 'when another user tries to return it' do
    let(:other_user) { create(:user) }

    before do
      AssignDeviceToUser.new(
        requesting_user: user,
        serial_number: serial_number,
        new_device_owner_id: user.id
      ).call
    end

    it 'raises Unauthorized' do
      expect {
        described_class.new(
          user: other_user,
          serial_number: serial_number,
          from_user: other_user.id
        ).call
      }.to raise_error(RegistrationError::Unauthorized)
    end
  end
end
