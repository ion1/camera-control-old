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

require 'cc/singleton'
require 'ssp/constants'
require 'ssp/protocol'

module SSP
  class Camera
    def initialize dev
      @dev = dev
      @ssp = Protocol.singleton
    end

    def preset_goto slot
      validate_slot slot
      @ssp.send ADDR_CAT_CAMERA, @dev, [PRESET_POSITION, slot]
    end

    def preset_set slot
      validate_slot slot
      @ssp.send ADDR_CAT_CAMERA, @dev, [PRESET_MEMORY, slot]
    end

    def menu
      @ssp.send ADDR_CAT_CAMERA, @dev, [MENU]
    end

    def enter
      @ssp.send ADDR_CAT_CAMERA, @dev, [ENTER]
    end

    def move pan, tilt, zoom
      pan  = [7, [-7, pan ].max].min
      tilt = [7, [-7, tilt].max].min
      zoom = [1, [-1, zoom].max].min

      cmd = [PTZ_CONTROL, 0x00, 0x00]

      if pan > 0
        cmd[1] |= 0x01  # right
      elsif pan < 0
        cmd[1] |= 0x02  # left
      end

      if tilt < 0
        cmd[1] |= 0x04  # up
      elsif tilt > 0
        cmd[1] |= 0x08  # down
      end

      if zoom < 0
        cmd[2] |= 0x40  # out
      elsif zoom > 0
        cmd[2] |= 0x80  # in
      end

      cmd[2] |= pan.abs
      cmd[2] |= tilt.abs << 3

      if cmd[1] == 0 and cmd[2] == 0
        cmd[0] = CONCLUSION
      end

      @ssp.send ADDR_CAT_CAMERA, @dev, cmd
    end

    private

    def validate_slot slot, who=caller(2)
      unless PRESET_RANGE.include? slot
        raise ArgumentError,
          "slot: expected #{PRESET_RANGE}, got #{slot.inspect}",
          who
      end
    end
  end
end

