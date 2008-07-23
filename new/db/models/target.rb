class Target < ActiveRecord::Base
  class AllocationError < RuntimeError; end

  has_one :ssp_camera_slot, :dependent => :nullify

  validates_presence_of :name

  def allocate_slot ssp_camera
    SspCameraSlot.transaction do
      orig_slot = ssp_camera_slot
      unless orig_slot.nil?
        # Free the old allocation first.
        orig_slot.target_id = nil
        orig_slot.save
      end

      new_slot = ssp_camera.ssp_camera_slots.free.first
      if new_slot.nil?
        raise AllocationError, "#{ssp_camera.inspect}: No free slots available"
      end

      new_slot.target = self
      new_slot.save

      reload
    end
  end
end

