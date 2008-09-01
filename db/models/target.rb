# camera-control – Control Sanyo PTZ cameras with a custom input board
# Copyright © 2008 Johan Kiviniemi
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51
# Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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

