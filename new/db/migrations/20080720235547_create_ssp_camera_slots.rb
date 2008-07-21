class CreateSspCameraSlots < ActiveRecord::Migration
  def self.up
    create_table :ssp_camera_slots do |t|
      t.belongs_to :ssp_camera
      t.belongs_to :target
      t.integer :slot, :null => false
    end

    add_index :ssp_camera_slots, [:ssp_camera_id, :slot], :unique => true
  end

  def self.down
    drop_table :ssp_camera_slots
  end
end

