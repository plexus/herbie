
require 'herbie/player'
require 'herbie/ui'
require 'herbie/model/playlist'
require 'herbie/controller/playlist_controller'

LOG = File.open('/tmp/herbie.log','a')

def log(msg); LOG << "[%s] %s\n" % [Time.now.strftime("%Y-%m-%d %H:%M:%S"), msg] ; LOG.flush end

module Herbie
  class Herbie
    def initialize
      @ui = UI.new
      @player = Player.new
      @pwd = ARGV[0] || `pwd`.strip
      
      @playlist = Playlist.new
      @playlist.append_files Dir[File.join(@pwd, '*.{mp3,m4a}').gsub('[','\[').gsub(']','\]')].sort
      
      @playlist_controller = PlaylistController.new(@ui, @playlist, @player)
      
      @playlist_controller.update_ui_playlist
      # @playlist_controller.play_next_song
    end

    def loop
      t = Thread.new {@ui.loop},
      @player.loop
      t.join
    end
  end
end

