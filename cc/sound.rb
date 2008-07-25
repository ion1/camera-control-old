module CC
  module Sound
    def self.info
      Thread.new do
        system "/usr/bin/aplay", "/usr/share/sounds/info.wav"
      end
    end
  end
end
