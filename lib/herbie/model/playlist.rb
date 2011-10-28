require 'herbie/util/watchable'
require 'forwardable'
module Herbie
  class Playlist
    extend Forwardable
  
    include Watchable
      # Watchable signals :
      # file_added(file)
      # file_removed(file, position)
    
    attr_reader :files
    
    def initialize
      @files = []
      @cursor = 0
      @playing = nil
    end
    
    def append_file(file)
      @files << PlayFile.new(file)
      notify_watchers :file_added, file
    end
    
    def append_files(files)
      files.each do |file|
        append_file file
      end
    end
    
    def shift
      file = nil
      unless empty?
        file = @files.shift
        notify_watchers :file_removed, file, 0 
      end
      file
    end
    
    def_delegators :@files, :empty?, :count, :first
  end
  
  class PlayFile
    def initialize(file)
      @file = file
    end
    
    def filename
      @file
    end
    
    def to_s
      File.basename(@file)
    end
  end
end
