require 'camera-control/camera'
require 'camera-control/control-board/delayed'
require 'camera-control/logger'
require 'camera-control/mapping'

module CameraControl
  class Main
    def initialize
      @running = true

      @num_cameras = 2  # XXX Config

      @board = ControlBoard::Delayed.new
      @cam   = Camera.new
      @map   = Mapping.new
      @log   = Logger.instance

      @current_camera = nil
      switch_camera 0

      @num_cameras.times do |cam_id|
        @cam.preset_goto cam_id, :rest
      end

      @board.add_delayed_callback :press do |keypress|
        cam_id, cam_slot = @map[keypress.y, keypress.x]

        if cam_id and cam_slot
          @log.info "Position: #{cam_id}/#{cam_slot}"
          switch_camera cam_id
          @cam.preset_goto cam_id, cam_slot

          # Move the other cameras to rest position.
          @num_cameras.times do |other_cam_id|
            next if other_cam_id == cam_id
            @cam.preset_goto other_cam_id, :rest
          end
        end
      end

      @board.add_delayed_callback :cancel do |keypress|
        previous_camera = @current_camera

        if @num_cameras > 1
          # Pick another camera, which is already in rest position.
          cam_id = (@current_camera + 1) % @num_cameras
        else
          cam_id = @current_camera
        end

        switch_camera cam_id
        @cam.preset_goto previous_camera, :rest
      end

      while @running
        @board.scan_input
      end

      close
    end

    def close
      @board.close
      @cam.close
    end

    private

    def switch_camera num
      if 0 <= num and num < @num_cameras
        @current_camera = num
        @board.switch_camera num
      end
    end
  end
end
