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
      cam_slot = 1 if cam_slot == :rest
      real_id = cam_id + 1

      validate_cam_slot cam_slot

      @ssp.send SSP::ADDR_CAT_CAMERA, real_id,
        [SSP::PRESET_POSITION, cam_slot]
    end

    def preset_set cam_id, cam_slot
      cam_slot = 1 if cam_slot == :rest
      real_id = cam_id + 1

      validate_cam_slot cam_slot

      @ssp.send SSP::ADDR_CAT_CAMERA, real_id,
        [SSP::PRESET_MEMORY, cam_slot]
    end

    def menu cam_id
      real_id = cam_id + 1
      @ssp.send SSP::ADDR_CAT_CAMERA, real_id, [SSP::MENU]
    end

    def enter cam_id
      real_id = cam_id + 1
      @ssp.send SSP::ADDR_CAT_CAMERA, real_id, [SSP::ENTER]
    end

    def move cam_id, x, y, z
      real_id = cam_id + 1

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

      @ssp.send SSP::ADDR_CAT_CAMERA, real_id, cmd
    end

    private

    def validate_cam_slot n, who=caller(2)
      unless (1 .. 127).include? n
        raise ArgumentError,
          "cam_slot: expected 1..127, given #{n.inspect}",
          who
      end
    end
  end
end
