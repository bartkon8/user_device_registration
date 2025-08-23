class Device < ApplicationRecord
    has_many :device_assignments, dependent: :destroy
    has_many :users, through: :device_assignments
end
