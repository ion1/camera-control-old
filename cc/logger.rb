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

require 'fileutils'
require 'logger'

module CC
  class Logger < ::Logger
    LOG_ROOT = File.expand_path '~/.local/share/camera-control'

    def initialize target=LOG_ROOT+'/camera-control.log'
      if target.is_a? String
        FileUtils.mkdir_p File.dirname(target)
      end

      super target, 10, 2**20

      self.progname = 'camera-control'
      self.level    = INFO
    end
  end
end
