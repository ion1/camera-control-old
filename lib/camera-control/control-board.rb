require 'camera-control/callbacks'
require 'camera-control/parport'

module CameraControl
  class ControlBoard
    class KeyPress < Struct.new :y, :x, :state; end

    def initialize port=ParPort::DEFAULT_PORT
      @port = ParPort.new port

      @callbacks = Callbacks.new

      @input_state = Array.new 16 do
        Array.new 16 do
          false
        end
      end

      @data    = 0
      @control = 0

      write_data
      write_control
    end

    def close
      @port.close
    end

    def add_callback &block
      @callbacks.add &block
    end

    def switch_camera num
      @control &= (0x01 ^ 0xff)
      @control |= 0x01 if num != 0

      write_control
    end

    def scan_input
      recv = [0] * 8

      8.times do |i|
        @data = i
        write_data
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

    private

    def write_data
      @port.write @data
    end

    def write_control
      @port.write_control @control
    end
  end
end
