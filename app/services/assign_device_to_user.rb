# frozen_string_literal: true

class AssignDeviceToUser
  def initialize(requesting_user:, serial_number:, new_device_owner_id:)

    @requesting_user = requesting_user
    @serial_number = serial_number
    @new_device_owner_id = new_device_owner_id
  end

  def call
    
    ActiveRecord::Base.transaction do
      if requesting_user.id != new_device_owner_id
        raise RegistrationError::Unauthorized, "You can't assign a device to another user"
      end
      
      device = Device.find_or_create_by!(serial_number: serial_number)

      if (active = DeviceAssignment.find_by(device: device, returned_at: nil)) &&
         active.user_id != new_device_owner_id
        raise AssigningError::AlreadyUsedOnOtherUser
      end
      
      if DeviceAssignment.exists?(device: device, user_id: new_device_owner_id)
        raise AssigningError::AlreadyUsedOnUser, "You can't assign the same device twice"
      end
      
      assignment = DeviceAssignment.create!(
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
