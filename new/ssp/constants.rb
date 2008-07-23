module SSP
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
  DELAY_BUS_FREE    = 0.100
  DELAY_RELEASE_BUS = 0.200
  DELAY_SHORT       = 0.040
  DELAY_HANDSHAKE   = 0.080
end
