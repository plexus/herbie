#
# Like observable, but allow for multiple types of
# notifications. Observers (watchers) are defined using
# a builder pattern.
#
module Herbie
  module Watchable
    attr_reader :watchers
    def watchers
      @watchers ||= Hash.new{|hsh,k| hsh[k]=[]}
    end
    
    # Declare watchers
    def watch(&blk)
      b=WatcherBuilder.new self
      yield b if block_given?
      b
    end

    protected
      # Send the named signal to all watchers that are waiting
      # for that signal.
      #
      # Return true if all watchers returns true
      def notify_watchers(name, *args)
        watchers[name].inject(true) {|res, w| res && w.call(*args)}
      end
  end

  class WatcherBuilder
    def initialize(watchable)
      @watchable = watchable
    end
    
    def method_missing(name,&blk)
      @watchable.watchers[name] << blk
    end
  end
end
