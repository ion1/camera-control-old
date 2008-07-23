require 'logger'

module CC
  class Logger < ::Logger
    def initialize *args
      args = [$stderr] if args.empty?
      super(*args)

      self.progname = 'camera-control'
      self.level    = INFO
    end
  end
end
