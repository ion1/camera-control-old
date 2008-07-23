module UI
  class Base
    def initialize
      @queue = []
    end

    def iterate
    end

    def flush_queue
      @queue.dup
    ensure
      @queue.clear
    end

    private

    def queue *event
      @queue << event
    end
  end
end
