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

require 'ssp/constants'

class SspCameraSlot < ActiveRecord::Base
  belongs_to :ssp_camera
  belongs_to :target

  named_scope :free,      :conditions => ['target_id IS NULL']
  named_scope :allocated, :conditions => ['target_id IS NOT NULL']

  validates_presence_of  :slot
  validates_inclusion_of :slot, :in => SSP::PRESET_RANGE
end

