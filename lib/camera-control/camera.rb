require 'camera-control/ssp'

module CameraControl
  class Camera
    def initialize
      @ssp = SSP.new
    end

    def close
      @ssp.close
    end

    def preset_goto cam_id, cam_slot
      if cam_slot == :rest
        cam_slot = 0
      end

      @ssp.send SSP::ADDR_CAT_CAMERA, cam_id,
        [SSP::PRESET_MEMORY, cam_slot]
    end

    def preset_set cam_id, cam_slot
      @ssp.send SSP::ADDR_CAT_CAMERA, cam_id,
        [SSP::PRESET_POSITION, cam_slot]
    end

    def menu cam_id
      @ssp.send SSP::ADDR_CAT_CAMERA, cam_id, [SSP::MENU]
    end

    def enter cam_id
      @ssp.send SSP::ADDR_CAT_CAMERA, cam_id, [SSP::ENTER]
    end

    def move cam_id, x, y, z
      x = [7, [-7, x].max].min
      y = [7, [-7, y].max].min
      z = [1, [-1, z].max].min

      cmd = [SSP::PTZ_CONTROL, 0x00, 0x00]
      if x > 0
        cmd[1] |= 0x01  # right
      elsif x < 0
        cmd[1] |= 0x02  # left
      end

      if y < 0
        cmd[1] |= 0x04  # up
      elsif y > 0
        cmd[1] |= 0x08  # down
      end

      if z < 0
        cmd[2] |= 0x40  # out
      elsif z > 0
        cmd[2] |= 0x80  # in
      end

      cmd[2] |= x.abs
      cmd[2] |= y.abs << 3

      if cmd[1] == 0 and cmd[2] == 0
        cmd[0] = SSP::CONCLUSION
      end

      @ssp.send SSP::ADDR_CAT_CAMERA, cam_id, cmd
    end
  end
end
