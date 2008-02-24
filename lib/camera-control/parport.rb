module CameraControl
  class BaseParPort
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
