require 'herbie/util/escape'

module Herbie
  # 
  class BrowserController
    
    def initialize(ui, playlist, browser)
      @ui = ui
      @playlist = playlist
      @browser = browser
      
      
      @ui.watch.keypress do |pos, key|
        next true unless pos == :bottom
        case key
        when ?\t
          @ui.focus_menu = :top
        when Ncurses::KEY_LEFT
          @browser.cd_up
          update_ui
        when Ncurses::KEY_RIGHT
          @browser.cd_into @ui.current_item
          update_ui
        when ?a
          file = File.join(@browser.current_dir, @ui.current_item)
          if File.file? file
            @playlist.append_file(file)
          elsif File.directory? file
            @playlist.append_files(Dir[File.join(Escape.glob(file), '**')].sort)
          end
        end
        true
      end

      update_ui
    end

    def update_ui
      @ui.set_status(:middle, @browser.current_dir)
      @ui.populate_menu(:bottom, @browser.ls.map {|f| f.directory? ? f.basename + '/' : f.basename})
    end
  end
end
