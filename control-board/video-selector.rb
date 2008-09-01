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

require 'cc/logger'
require 'cc/parport'
require 'cc/singleton'

module ControlBoard
  class VideoSelector
    def initialize
      @port = CC::ParPort.singleton
      @log  = CC::Logger.singleton
    end

    def select num
      # Currently only two video inputs are supported.
      control = @port.control

      control &= (0x01 ^ 0xff)
      control |= 0x01 if num != 0

      @port.control = control

      @log.debug "Selected video signal #{num}"
    end
  end
end
