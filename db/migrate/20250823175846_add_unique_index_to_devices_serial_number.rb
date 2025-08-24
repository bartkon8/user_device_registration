class AddUniqueIndexToDevicesSerialNumber < ActiveRecord::Migration[7.1]
  def change
    add_index :devices, :serial_number, unique: true
  end
end
