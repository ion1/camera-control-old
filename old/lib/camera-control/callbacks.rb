module CameraControl
  class Callbacks
    def initialize
      @callbacks = []
    end

    def add &block
      @callbacks << block
    end

    def call *args
      @callbacks.each {|cb| cb.call *args }
    end
  end
end
