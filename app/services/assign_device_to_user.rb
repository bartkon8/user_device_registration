# frozen_string_literal: true

class AssignDeviceToUser
  def initialize(requesting_user:, serial_number:, new_device_owner_id:)

    @requesting_user = requesting_user
    @serial_number = serial_number
    @new_device_owner_id = new_device_owner_id
  end

  def call
    ActiveRecord::Base.transaction do
      device = Device.find_or_create_by!(serial_number: serial_number)
      return unless device
      DeviceAssignment.create!(
        device: device,
        user_id: new_device_owner_id,
        assigned_at: Time.current
      )
      device    
    end
  end

  private

  attr_reader :requesting_user, :serial_number, :new_device_owner_id
end
