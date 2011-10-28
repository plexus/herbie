require 'ncurses'
require 'herbie/util/watchable'

module Herbie
  #
  # Ncurses user interface
  #
  class UI
    include Watchable
    
    def initialize
      @nc = Ncurses
      @top_window_percent = 0.4
      %w(initscr start_color cbreak noecho nonl).each {|s| @nc.send s}
      # cbreak : provide unbuffered input
      # noecho : don't echo input
      # nonl : Turn of line-ending processing
      @nc.curs_set(0) # Remove the actual cursor

      @colors = init_colors
      @windows = init_windows
      @menus = {}
      @focus_menu = :top
      
      resize_windows
    end

    def loop
      begin
        menu = @menus[@focus_menu]
        menu_win = menu.win
        @nc.keypad(menu_win, true)
        @nc.refresh
        menu_win.wrefresh
        while (char = menu_win.getch) do
          case char
          when @nc::KEY_DOWN
            @nc::Menu.menu_driver(menu, @nc::Menu::REQ_DOWN_ITEM)
          when @nc::KEY_UP
            @nc::Menu.menu_driver(menu, @nc::Menu::REQ_UP_ITEM)
          when @nc::KEY_ENTER, ?1, ?\r, ?\n
            #break
          when @nc::KEY_RESIZE
            resize_windows
          else
            break unless notify_watchers :keypress, char
          end
          menu = @menus[@focus_menu]
          menu_win = menu.win
          @nc.keypad(menu_win, true)
          @nc.refresh
          menu_win.wrefresh
        end
      ensure
        @nc.endwin
      end
    end

    def init_colors
      @nc.init_pair 1, @nc::COLOR_WHITE, @nc::COLOR_BLUE
      @nc.init_pair 2, @nc::COLOR_WHITE, @nc::COLOR_BLACK
      @nc.init_pair 3, @nc::COLOR_WHITE, @nc::COLOR_CYAN
      {
        :statusbar => @nc.COLOR_PAIR(1),
        :window => @nc.COLOR_PAIR(2),
        :focus => @nc.COLOR_PAIR(3)
      }
    end

    def init_windows
      windows = {
        #:stdscr => @nc.stdscr
        }
      
      [:top_bar, :middle_bar, :bottom_bar].each do |name|
        win = @nc.newwin(0,0,0,0)
        win.bkgd @colors[:statusbar]
        windows[name] = win
      end

      [:top, :bottom].each do |name|
        win = @nc.newwin(0,0,0,0)
        win.bkgd @colors[:window]
        windows[name] = win
      end

      windows
    end

    def resize_windows
      maxx, maxy = *screen_size

      height1 = (maxy - 3) * @top_window_percent
      height2 = maxy - 3 - height1
      {
        #:stdscr => [[0, 0], [0,0]],
        :top_bar    => [[1, maxx],       [0, 0]],
        :middle_bar => [[1, maxx],       [1 + height1, 0]],
        :bottom_bar => [[1, maxx],       [2 + height1 + height2, 0]],
        
        :top    => [[height1, maxx], [1, 0]],
        :bottom => [[height2, maxx], [2 + height1, 0]]
      }.each do |name, (dim, pos)|
        win = @windows[name]
        win.mvwin(*pos)
        win.wresize(*dim)
      end
      
      @windows.each do |k,w|
        if @menus.has_key? k 
          @menus[k].unpost
          @menus[k].post
          @nc.touchwin(@menus[k].sub)
          @menus[k].sub.wrefresh
        end 
        win = @windows[k]
        @nc.touchwin(w) 
        win.wrefresh
      end
      
      @nc.refresh
    end
    
    def create_menu(pos)
      win = @windows[pos]
      menu = @nc::Menu.new_menu([])
      menu.set_menu_win(win)
      menu
    end

    def populate_menu(pos, items)
      if @menus[pos]
        @menus[pos].free
      end
      @menus[pos] = create_menu(pos)
      items = items.map do |itemdata|
        item = @nc::Menu.new_item(itemdata.to_s, '')
        item.user_object = itemdata
        item
      end
      menu = @menus[pos]
      menu.items = items
      win = @windows[pos]
      menu.set_menu_win(win)
      menu.unpost
      menu.post

      resize_windows
    end

    def screen_size
      @nc.refresh # needed to get accurate screen_size
      rows, cols = [], []
      @nc.getmaxyx @nc.stdscr, rows, cols
      maxx = cols.first
      maxy = rows.first
      [maxx, maxy]
    end
    
    def set_status(pos, msg)
      @windows["#{pos}_bar".to_sym].addstr(msg)
    end
  end
end