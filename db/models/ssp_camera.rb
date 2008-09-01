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

