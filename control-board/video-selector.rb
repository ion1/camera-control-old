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
