require 'camera-control/callbacks'
require 'camera-control/control-board'
require 'camera-control/logger'

module CameraControl
  class ControlBoard
    class Delayed < self
      def initialize grace_time=5.0, port=ParPort::DEFAULT_PORT
        super(port)

        @delayed_callbacks = {
          :cancel => Callbacks.new,
          :press  => Callbacks.new,
        }

        logger = Logger.instance

        last_keypress    = KeyPress.new nil, nil, false
        last_keypress_at = Time.at 0

        add_callback do |keypress|
          # Ignore releases
          if keypress.state
            now = Time.now

            if keypress == last_keypress
              logger.debug "CANCEL %2d,%2d" % [keypress.y, keypress.x]
              @delayed_callbacks[:cancel].call keypress
              last_keypress.x  = last_keypress.y = nil
              last_keypress_at = Time.at 0

            elsif now > last_keypress_at + grace_time
              logger.debug "PRESS  %2d,%2d" % [keypress.y, keypress.x]
              @delayed_callbacks[:press].call keypress
              last_keypress    = keypress
              last_keypress_at = now

            else
              logger.debug "IGNORE %2d,%2d" % [keypress.y, keypress.x]
            end
          end
        end
      end

      def add_delayed_callback event, &block
        unless @delayed_callbacks[event]
          raise ArgumentError, "Unknown event #{event.inspect}"
        end

        @delayed_callbacks[event].add &block
      end
    end
  end
end
