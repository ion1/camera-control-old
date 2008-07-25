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
