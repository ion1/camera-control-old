class Target < ActiveRecord::Base
  has_one :ssp_camera_slot, :dependent => :nullify

  validates_presence_of :name
end

