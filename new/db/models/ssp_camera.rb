class SspCamera < ActiveRecord::Base
  has_many :ssp_camera_slots, :dependent => :destroy

  validates_presence_of  :dev
  validates_inclusion_of :dev, :in => (0..127)

  def after_create
    # Create slots.
    ary = (1..127).map do |i|
      { :slot => i }
    end

    ssp_camera_slots.create ary
  end
end

