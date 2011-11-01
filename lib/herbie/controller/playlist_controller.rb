module Herbie
  # 
  class PlaylistController
    
    def initialize(ui, playlist, player)
      @ui = ui
      @playlist = playlist
      @player = player
    
      @player.watch.end_of_stream do |msg|
        play_next_song
      end
      
      @playlist.watch do |w|
        w.file_added do |file|
          update_ui_playlist
        end
        
        w.file_removed do |file, pos|
          update_ui_playlist
        end
      end

      @ui.watch.keypress do |pos, key|
        next true unless pos == :top
        case key
        when ?n, ?N
          play_next_song
        when ?\t
          @ui.focus_menu = :bottom
        end
        true
      end
    end
    
    def update_ui_playlist
      @ui.populate_menu(:top, @playlist.files)
    end
    
    def play_next_song
      unless @playlist.empty?
        file = @playlist.shift
        @player.playfile(file.filename)
        @player.play
        @ui.set_status :top, file
        update_ui_playlist
      end
    end
    
  end
end
