class User < ApplicationRecord
  has_many :api_keys, as: :bearer
  has_secure_password
  has_many :device_assignments, dependent: :destroy
  has_many :devices, through: :device_assignments
end
