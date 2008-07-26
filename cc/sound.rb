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
