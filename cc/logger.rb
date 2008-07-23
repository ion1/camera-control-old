require 'fileutils'
require 'logger'

module CC
  class Logger < ::Logger
    LOG_ROOT = File.expand_path '~/.local/share/camera-control'

    def initialize *args
      args = [LOG_ROOT+'/camera-control.log'] if args.empty?
      super(*args)

      self.progname = 'camera-control'
      self.level    = INFO
    end
  end
end
