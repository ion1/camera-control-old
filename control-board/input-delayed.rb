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
require 'cc/logger'
require 'control-board/input'

module ControlBoard
  class InputDelayed
    def initialize grace_time=1.0
      super()

      input = Input.singleton

      @callbacks = {
        :cancel => CC::Callbacks.new,
        :press  => CC::Callbacks.new,
      }

      logger = CC::Logger.singleton

      last_keypress    = Input::KeyPress.new nil, nil, false
      last_keypress_at = Time.at 0

      input.add_callback do |keypress|
        # Ignore releases
        if keypress.state
          now = Time.now

          if keypress == last_keypress
            logger.debug "CANCEL %2d,%2d" % [keypress.y, keypress.x]
            @callbacks[:cancel].call keypress
            last_keypress.x  = last_keypress.y = nil
            last_keypress_at = Time.at 0

          elsif now > last_keypress_at + grace_time
            logger.debug "PRESS  %2d,%2d" % [keypress.y, keypress.x]
            @callbacks[:press].call keypress
            last_keypress    = keypress
            last_keypress_at = now

          else
            logger.debug "IGNORE %2d,%2d" % [keypress.y, keypress.x]
          end
        end
      end
    end

    def add_callback event, &block
      unless @callbacks[event]
        raise ArgumentError, "Unknown event #{event.inspect}", caller
      end

      @callbacks[event].add &block
    end
  end
end
