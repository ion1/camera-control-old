require 'ssp/constants'

class SspCameraSlot < ActiveRecord::Base
  belongs_to :ssp_camera
  belongs_to :target

  named_scope :free,      :conditions => ['target_id IS NULL']
  named_scope :allocated, :conditions => ['target_id IS NOT NULL']

  validates_presence_of  :slot
  validates_inclusion_of :slot, :in => SSP::PRESET_RANGE
end

