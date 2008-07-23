require 'cc/callbacks'
require 'cc/logger'
require 'control-board/input'

module ControlBoard
  class InputDelayed
    def initialize grace_time=5.0
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
