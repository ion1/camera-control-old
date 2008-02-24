require 'serialport'

require 'camera-control/logger'

module CameraControl
  class SSP
    class SentCommand < Struct.new :addr_cat, :addr_dev, :time; end

    # First address byte: categories
    ADDR_CAT_ALL         = 0xf0
    ADDR_CAT_CONTROLLER  = 0xf1
    ADDR_CAT_MULTIPLEXER = 0xf2
    ADDR_CAT_VCR         = 0xf3
    ADDR_CAT_CAMERA      = 0xf4
    ADDR_CAT_DVR         = 0xf5
    ADDR_CAT_OTHER       = 0xf7

    # Second address byte: devices
    ADDR_DEV_MAX            = 0x7f
    ADDR_DEV_CONTROLLER_MAX = 0x04
    ADDR_DEV_BROADCAST      = 0xe0
    ADDR_DEV_BROADCAST_MAX  = 0xef

    # Commands
    ACK                  = 0x0a
    CONCLUSION           = 0x1e
    CONTINUOUS           = 0x1f
    ENTER                = 0x40
    MENU                 = 0x74
    OSD_EXIT             = 0x8e
    PAN_DIRECT           = 0x42
    PRESET_MEMORY        = 0x26
    PRESET_POSITION      = 0xb8
    PTZ_CONTROL          = 0x25
    RECEIVE_CONFIRMATION = 0xfe
    SCREEN_SHOT          = 0x45
    SHIFT_DOWN           = 0x64
    SHIFT_LEFT           = 0x53
    SHIFT_RIGHT          = 0x63
    SHIFT_UP             = 0x54
    TILT_DIRECT          = 0x43
    TRANSMISSION_START   = 0xfd
    ZOOM_DIRECT          = 0x44

    # Delays
    DELAY_RELEASE_BUS = 0.140
    DELAY_LONG        = 0.060
    DELAY_SHORT       = 0.040

    def initialize device=0, my_addr=0
      @port = SerialPort.new device
      @port.baud = 2400

      @my_addr = my_addr

      @sent_cmd = SentCommand.new 0, 0, 0.0

      @sleep_until = 0.0

      @log = Logger.instance
      @log_bytes = []
    end

    def close
      @port.close
    end

    def send addr_cat, addr_dev, data
      bus_free_at = @sleep_until + DELAY_RELEASE_BUS

      first_cmd = @sent_cmd.time == 0.0
      bus_free  = bus_free_at <= Time.now.to_f
      same_addr = @sent_cmd.addr_cat == addr_cat &&
                  @sent_cmd.addr_dev == addr_dev

      unless first_cmd or bus_free or same_addr
        # The previous command was sent to another address. We need to sleep
        # before sending commands to a new address.
        @sleep_until = bus_free_at
        bus_free = true
      end

      if first_cmd or bus_free
        # Do the handshaking.
        send_8 ADDR_CAT_CONTROLLER
        send_8 @my_addr
        send_8 addr_cat
        send_8 addr_dev,           DELAY_LONG
        # receive RECEIVE_CONFIRMATION
        send_8 TRANSMISSION_START, DELAY_LONG*2
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

      @sleep_until += DELAY_LONG

      @sent_cmd.addr_cat = addr_cat
      @sent_cmd.addr_dev = addr_dev
      @sent_cmd.time     = Time.now.to_f

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
