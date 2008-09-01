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
  ADDR_DEV_MIN   = 0x00
  ADDR_DEV_MAX   = 0x7f
  ADDR_DEV_RANGE = (ADDR_DEV_MIN .. ADDR_DEV_MAX)

  ADDR_DEV_CONTROLLER_MIN   = 0x00
  ADDR_DEV_CONTROLLER_MAX   = 0x04
  ADDR_DEV_CONTROLLER_RANGE = (ADDR_DEV_CONTROLLER_MIN ..
                               ADDR_DEV_CONTROLLER_MAX)

  ADDR_DEV_BROADCAST             = 0xe0
  ADDR_DEV_BROADCAST_GROUP_MIN   = 0xe1
  ADDR_DEV_BROADCAST_GROUP_MAX   = 0xef
  ADDR_DEV_BROADCAST_GROUP_RANGE = (ADDR_DEV_BROADCAST_GROUP_MIN ..
                                    ADDR_DEV_BROADCAST_GROUP_MAX)

  # Memory slots
  PRESET_MIN   = 0x01
  PRESET_MAX   = 0x7f
  PRESET_RANGE = (PRESET_MIN .. PRESET_MAX)

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
