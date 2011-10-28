#!/usr/bin/env ruby1.8

require 'ncurses'

Ncurses.initscr
Ncurses.start_color
Ncurses.cbreak                  # provide unbuffered input
Ncurses.noecho                  # don't echo input
Ncurses.nonl                    # Turn of line-ending processing
#Ncurses.stdscr.intrflush(false) # turn off flush-on-interrupt
#Ncurses.stdscr.keypad(true)     # turn on keypad mode
Ncurses.curs_set(0)             # Remove the actual curso

itemnames = %w(appels peren bananen)

items = itemnames.map do |name|
  Ncurses::Menu.new_item(name, name)
end

menu = Ncurses::Menu.new_menu(items)

menu_win = Ncurses.newwin(15, 15, 5, 5)

menu.set_menu_win(menu_win)
Ncurses.keypad(menu_win, true)

Ncurses.refresh
menu.post_menu
menu_win.wrefresh

menu.set_menu_mark(" * ")

#menu_win.box(0,0)
    
menu_win.wrefresh
while (char = menu_win.getch) do
  case char
  when Ncurses::KEY_DOWN
    Ncurses::Menu.menu_driver(menu, Ncurses::Menu::REQ_DOWN_ITEM)
  when Ncurses::KEY_UP
    Ncurses::Menu.menu_driver(menu, Ncurses::Menu::REQ_UP_ITEM)
  when Ncurses::KEY_ENTER, ?1, ?\r, ?\n
    break
  when Ncurses::KEY_RESIZE
    Ncurses::Menu.menu_driver(menu, Ncurses::Menu::REQ_DOWN_ITEM)
  else  :do_nothing
  end
  menu_win.wrefresh
end

Ncurses.endwin
