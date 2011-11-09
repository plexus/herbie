require 'herbie/util/watchable'
require 'herbie/util/filename'
require 'herbie/util/escape'

module Herbie
  class Browser
    include Watchable
    
    attr_accessor :current_dir

    def initialize(current_dir = ENV['PWD'])
      @current_dir = current_dir
      @pos = 0
    end

    def cd_up
      @current_dir = File.split(@current_dir)[0]
      notify_watchers :directory_changed, @current_dir
    end

    def ls
      Dir[Escape.glob(@current_dir) + '/*'].map{|s| s.extend(Filename)}.sort
    end

    def cd_into(dir)
      @current_dir = File.join(@current_dir, dir)
      notify_watchers :directory_changed, @current_dir
    end

    def size
      ls.size
    end

    def pos=(p)
      if p >= ls.size
        p = ls.size-1
      end
      @pos = p
      notify_watchers :position, p
    end
  end
end
