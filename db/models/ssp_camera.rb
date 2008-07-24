require 'ssp/constants'

class SspCamera < ActiveRecord::Base
  has_many :ssp_camera_slots, :dependent => :destroy

  validates_presence_of  :dev
  validates_inclusion_of :dev, :in => SSP::ADDR_DEV_RANGE

  def after_create
    # Create slots.
    ary = SSP::PRESET_RANGE.map do |i|
      { :slot => i }
    end

    ssp_camera_slots.create ary
  end
end

