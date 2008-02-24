require 'logger'
require 'singleton'

module CameraControl
  class Logger < ::Logger
    include Singleton

    def initialize *args
      args = [$stderr] if args.empty?
      super(*args)

      self.progname = 'camera-control'
      self.level    = INFO
    end
  end
end
