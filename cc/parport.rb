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

module CC
  class BaseParPort
    def initialize
      @data    = 0
      @control = 0
    end

    # The data and control readers only return what was last written using the
    # equivalent writer. To be used like ‘data |= 0x04’.

    attr_reader :data
    def data= new_data
      write new_data
      @data = new_data
    end

    attr_reader :control
    def control= new_control
      write_control new_control
      @control = new_control
    end

    def to_s
      "#<#{self.class} #{@port}>"
    end

    def inspect
      to_s
    end

    module IOExtensions
      def ioctl_pack cmd, tmpl, arg
        ioctl cmd, [arg].pack(tmpl)
      end

      def ioctl_read_pack cmd, tmpl, init=0
        init = [init] unless init.respond_to? :pack
        res = init.pack(tmpl)
        ioctl cmd, res
        res = res.unpack(tmpl)
        if res.length == 1 then res.first else res end
      end
    end
  end

  case RUBY_PLATFORM
  when /\blinux\b/
    class ParPort < BaseParPort
      DEFAULT_PORT = '/dev/parport0'

      # misc/linux_ppdev_constants.c
      PPRSTATUS  = 0x80017081
      PPRCONTROL = 0x80017083
      PPWCONTROL = 0x40017084
      PPRDATA    = 0x80017085
      PPWDATA    = 0x40017086
      PPCLAIM    = 0x0000708b
      PPRELEASE  = 0x0000708c
      PPEXCL     = 0x0000708f
      PPDATADIR  = 0x40047090

      def initialize port=DEFAULT_PORT
        super()

        @port = port

        @io = open @port, 'a+b'
        @io.extend IOExtensions

        @io.ioctl PPEXCL
        @io.ioctl PPCLAIM
      end

      def close
        @io.ioctl PPRELEASE
        @io.close
        nil
      end

      def write arg
        @io.ioctl_pack PPDATADIR, 'i', 0
        @io.ioctl_pack PPWDATA, 'C', arg
        nil
      end

      def read
        @io.ioctl_pack PPDATADIR, 'i', 1
        @io.ioctl_read_pack PPRDATA, 'C'
      end

      def write_control arg
        @io.ioctl_pack PPWCONTROL, 'C', arg
        nil
      end

      def read_control
        @io.ioctl_read_pack PPRCONTROL, 'C'
      end

      def read_status
        @io.ioctl_read_pack(PPRSTATUS, 'C') ^ 0x80  # Invert −BUSY
      end
    end

  else
    raise RuntimeError,
      "No ParPort implementation for #{RUBY_PLATFORM} yet, sorry"
  end
end
