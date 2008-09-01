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

require 'cc/callbacks'
require 'cc/parport'
require 'cc/singleton'

module ControlBoard
  class Input
    class KeyPress < Struct.new :y, :x, :state; end

    def initialize
      @port = CC::ParPort.singleton

      @callbacks = CC::Callbacks.new

      @input_state = Array.new 16 do
        Array.new 16 do
          false
        end
      end
    end

    def add_callback &block
      @callbacks.add &block
    end

    def scan
      recv = [0] * 8

      8.times do |i|
        @port.data = i
        sleep 0.0001

        recv[i] = @port.read_status
        sleep 0.0001

        recv[i] >>= 4     # Only use bits 4..7
        recv[i] ^=  0x0f  # Invert them
      end

      16.times do |y|
        val_y = recv[y>>2] &  # The recv byte that corresponds to this row
                (1 << (y%4))  # The bit that is set if the row is on

        16.times do |x|
          val_x = recv[4 + (x>>2)] &  # The recv byte that corrs to this col
                  (1 << (x%4))        # The bit that is set if the col is on

          # Is there a connection on both the row and the column?
          state = (val_x != 0) && (val_y != 0)

          old_state = @input_state[y][x]
          @input_state[y][x] = state

          if old_state != state
            keypress = KeyPress.new y, x, state
            @callbacks.call keypress
          end
        end
      end
    end
  end
end
