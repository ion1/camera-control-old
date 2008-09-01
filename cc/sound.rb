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

require 'iconv'

module CC
  module Sound
    def self.info
      Thread.new do
        system "/usr/bin/aplay", "/usr/share/sounds/info.wav"
      end
    end

    def self.speak language, text
      Thread.new do
        IO.popen '-', 'w' do |io|
          unless io
            # Child.
            exec '/usr/bin/festival', '-b', '--language', language,
                 '(tts_file "-")'
            exit 1
          end

          io.puts Iconv.conv('latin1//translit', 'utf-8', text)
        end
      end
    end
  end
end
