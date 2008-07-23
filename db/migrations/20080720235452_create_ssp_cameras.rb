class CreateSspCameras < ActiveRecord::Migration
  def self.up
    create_table :ssp_cameras do |t|
      t.integer :dev, :null => false
    end

    add_index :ssp_cameras, :dev, :unique => true
  end

  def self.down
    drop_table :ssp_cameras
  end
end

