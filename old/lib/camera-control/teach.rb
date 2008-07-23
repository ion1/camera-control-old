require 'sdl'

require 'camera-control/camera'
require 'camera-control/control-board'
require 'camera-control/logger'
require 'camera-control/mapping'

module CameraControl
  class Teach
    def initialize
      @running = true

      @num_cameras = 2  # XXX Config

      @board = ControlBoard.new
      @cam   = Camera.new
      @map   = Mapping.new
      @log   = Logger.instance

      @screen = nil
      init_sdl

      @current_camera = nil
      switch_camera 0

      @num_cameras.times do |cam_id|
        @cam.preset_goto cam_id, :rest
      end

      @board.add_callback do |keypress|
        # Ignore if button is released.
        if keypress.state
          cam_id = @current_camera
          cam_slot = @map.set keypress.y, keypress.x, cam_id
          @cam.preset_set cam_id, cam_slot
          @log.info "Saved position: #{cam_id}/#{cam_slot}"
        end
      end

      motion = Struct.new(:x, :y, :z).new 0, 0, 0

      sdl_num_keys = [
        SDL::Key::K1, SDL::Key::K2, SDL::Key::K3, SDL::Key::K4, SDL::Key::K5,
        SDL::Key::K6, SDL::Key::K7, SDL::Key::K8, SDL::Key::K9, SDL::Key::K0,
      ]

      while @running
        @board.scan_input

        if ev = SDL::Event2.poll
          if ev.is_a? SDL::Event2::Quit
            @running = false

          elsif ev.is_a? SDL::Event2::KeyDown
            if ev.sym == SDL::Key::ESCAPE
              @running = false

            elsif sdl_num_keys.include? ev.sym
              switch_camera sdl_num_keys.index(ev.sym)
              motion.x = motion.y = motion.z = 0

            elsif ev.sym == SDL::Key::SPACE
              # Set the rest position.
              cam_id = @current_camera
              @cam.preset_set cam_id, :rest
              @log.info "Saved the rest position: #{cam_id}/1"

            elsif ev.sym == SDL::Key::LEFT
              motion.x = -7
            elsif ev.sym == SDL::Key::RIGHT
              motion.x = 7
            elsif ev.sym == SDL::Key::UP
              motion.y = -7
            elsif ev.sym == SDL::Key::DOWN
              motion.y = 7
            elsif ev.sym == SDL::Key::PAGEUP
              motion.z = 1
            elsif ev.sym == SDL::Key::PAGEUP
              motion.z = -1
            end

          elsif ev.is_a? SDL::Event2::KeyUp
            if ev.sym == SDL::Key::LEFT or ev.sym == SDL::Key::RIGHT
              motion.x = 0
            elsif ev.sym == SDL::Key::UP or ev.sym == SDL::Key::DOWN
              motion.y = 0
            elsif ev.sym == SDL::Key::PAGEUP or ev.sym == SDL::Key::PAGEDOWN
              motion.z = 0
            end
          end
        end

        @cam.move @current_camera, motion.x, motion.y, motion.z
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

    def init_sdl
      SDL.init SDL::INIT_VIDEO
      SDL::WM.set_caption 'Camera Control', 'camera-control'
      @screen = SDL::set_video_mode 256, 256, 16, SDL::SWSURFACE
      SDL::WM.grab_input true
      SDL::Mouse.hide
    end
  end
end
