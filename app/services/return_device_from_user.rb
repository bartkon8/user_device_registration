# frozen_string_literal: true

class ReturnDeviceFromUser
  def initialize(user:, serial_number:, from_user:)
    @user = user
    @serial_number = serial_number
    @from_user = from_user
  end

  def call
    ActiveRecord::Base.transaction do
      device = Device.find_by(serial_number: serial_number)
      raise AssigningError::DeviceNotFound unless device 

      active_assignment = DeviceAssignment.find_by(device: device, returned_at: nil)
      raise AssigningError::NotAssigned unless active_assignment

      unless active_assignment.user_id == user.id && from_user == user.id
        raise RegistrationError::Unauthorized
      end

      active_assignment.update!(returned_at: Time.current)
      device.update!(current_owner_id: nil) if device.respond_to?(:current_owner_id)

      active_assignment
    
    end
  end
  private
  attr_reader :user, :serial_number, :from_user
end
