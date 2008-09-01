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

# serialport breaks with rubygems require.
Kernel.require 'serialport'

require 'cc/logger'
require 'ssp/constants'

module SSP
  class Protocol
    class SentCommand < Struct.new :addr_cat, :addr_dev, :time; end

    def initialize device=0, my_addr=0
      @port = SerialPort.new device
      @port.baud = 2400

      @my_addr = my_addr

      @sent_cmd = SentCommand.new 0, 0, 0.0

      @sleep_until = 0.0

      @log = CC::Logger.singleton
      @log_bytes = []
    end

    def close
      @port.close
    end

    def send addr_cat, addr_dev, data
      # Commands are not sent without handshake if this delay has passed.
      bus_free_at          = @sent_cmd.time + DELAY_BUS_FREE
      # Delay a bit more before the handshake to make sure the bus is free.
      bus_free_for_sure_at = @sent_cmd.time + DELAY_RELEASE_BUS

      first_cmd = @sent_cmd.time == 0.0
      bus_free  = bus_free_at <= Time.now.to_f
      same_addr = @sent_cmd.addr_cat == addr_cat &&
        @sent_cmd.addr_dev == addr_dev

      need_handshake = false

      if first_cmd
        need_handshake = true
      else
        if bus_free or not same_addr
          # Sleep a bit extra to make sure the bus is free.
          @sleep_until   = bus_free_for_sure_at
          need_handshake = true
        end
      end

      if need_handshake
        # Do the handshaking.
        send_8 ADDR_CAT_CONTROLLER
        send_8 @my_addr
        send_8 addr_cat
        send_8 addr_dev
        # receive RECEIVE_CONFIRMATION
        send_8 TRANSMISSION_START, DELAY_HANDSHAKE
        # receive ACK
      end

      type = :'8'
      data.each do |item|
        case item
        when Integer
          if type == :'16'
            send_16 item
            type = :'8'
          else
            send_8 item
          end

        when Symbol
          if item == :'16'
            type = :'16'
          else
            raise ArgumentError, "Invalid symbol #{item.inspect}"
          end

        else
          raise ArgumentError, "Invalid data #{item.inspect}"
        end
      end

      @sent_cmd.addr_cat = addr_cat
      @sent_cmd.addr_dev = addr_dev
      @sent_cmd.time     = Time.now.to_f

      @sleep_until += DELAY_SHORT

      @log.debug "SSP: sent %s" % @log_bytes.map {|b| "%02x" % b }.join(' ')
      @log_bytes.clear
    end

    private

    def send_8 byte, delay=DELAY_SHORT
      @log_bytes << byte
      sleep_until @sleep_until
      @sleep_until = Time.now.to_f + delay
      @port.write [byte].pack('C')
    end

    def send_16 val, delay=DELAY_SHORT
      msb = (val >> 8) & 0xff
      lsb = val & 0xff

      send_8 msb, delay
      send_8 lsb, delay
    end

    def send_str str, delay=DELAY_SHORT
      str.unpack('C*').each do |byte|
        send_8 byte, delay
      end
    end

    def sleep_until time
      secs = time - Time.now.to_f
      sleep secs if secs > 0.0
    end
  end
end
