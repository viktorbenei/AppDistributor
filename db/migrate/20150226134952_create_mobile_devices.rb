class CreateMobileDevices < ActiveRecord::Migration
  def change
    create_table :mobile_devices do |t|
      t.string :udid
      t.string :version
      t.string :product

      t.timestamps null: false
    end
  end
end
