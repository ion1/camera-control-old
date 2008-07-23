module CC
  module Singleton
    def self.create klass, *args
      @@singletons ||= Hash.new {|hash, key| hash[key] = {} }
      @@singletons[klass][args] ||= klass.new *args
    end
  end
end

class Class
  def singleton *args
    CC::Singleton.create self, *args
  end
end

