class DeviceAssignment < ApplicationRecord
  belongs_to :device
  belongs_to :user

  scope :active, -> { where(returned_at: nil) }
end
