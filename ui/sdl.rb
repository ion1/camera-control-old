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

require 'sdl'

require 'ui/base'

module UI
  class SDL < Base
    NUM_KEYS = [
      ::SDL::Key::K1, ::SDL::Key::K2, ::SDL::Key::K3, ::SDL::Key::K4,
      ::SDL::Key::K5, ::SDL::Key::K6, ::SDL::Key::K7, ::SDL::Key::K8,
      ::SDL::Key::K9, ::SDL::Key::K0,
    ]

    def initialize
      super()

      ::SDL.init ::SDL::INIT_VIDEO
      ::SDL::WM.set_caption 'Camera Control', 'camera-control'

      @screen = ::SDL.set_video_mode 200, 200, 16, ::SDL::SWSURFACE
      ::SDL::WM.grab_input true
      ::SDL::Mouse.hide
    end

    def iterate
      while ev = ::SDL::Event2.poll
        if ev.is_a? ::SDL::Event2::Quit
          queue :quit

        elsif ev.is_a? ::SDL::Event2::KeyDown
          if ev.sym == ::SDL::Key::ESCAPE
            queue :quit

          elsif NUM_KEYS.include? ev.sym
            queue :switch_camera, NUM_KEYS.index(ev.sym)

          elsif ev.sym == ::SDL::Key::F1
            queue :mode, :normal

          elsif ev.sym == ::SDL::Key::F2
            queue :mode, :teach

          elsif ev.sym == ::SDL::Key::M
            queue :menu

          elsif ev.sym == ::SDL::Key::RETURN
            queue :enter

          elsif ev.sym == ::SDL::Key::SPACE
            # Set the rest position
            queue :save, 'rest'

          elsif ev.sym == ::SDL::Key::LEFT
            queue :motion, :pan, -1

          elsif ev.sym == ::SDL::Key::RIGHT
            queue :motion, :pan, 1

          elsif ev.sym == ::SDL::Key::UP
            queue :motion, :tilt, -1

          elsif ev.sym == ::SDL::Key::DOWN
            queue :motion, :tilt, 1

          elsif ev.sym == ::SDL::Key::PAGEUP
            queue :motion, :zoom, 1

          elsif ev.sym == ::SDL::Key::PAGEDOWN
            queue :motion, :zoom, -1
          end

        elsif ev.is_a? ::SDL::Event2::KeyUp
          if ev.sym == ::SDL::Key::LEFT or ev.sym == ::SDL::Key::RIGHT
            queue :motion, :pan, 0
          elsif ev.sym == ::SDL::Key::UP or ev.sym == ::SDL::Key::DOWN
            queue :motion, :tilt, 0
          elsif ev.sym == ::SDL::Key::PAGEUP or ev.sym == ::SDL::Key::PAGEDOWN
            queue :motion, :zoom, 0
          end
        end
      end
    end
  end
end
