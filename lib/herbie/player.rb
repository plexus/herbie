require 'gst'
require 'herbie/util/watchable'

module Herbie
  #
  # Play files through GStreamer
  #
  class Player
    include Watchable

    def initialize
      Gst.init
      @playbin = Gst::ElementFactory.make('playbin2')
      @playbin.bus.add_watch do |bus, message|
        notify_watchers :end_of_stream, message if message.type == Gst::Message::Type::EOS
        true
      end
    end

    def playfile(file)
      @playbin.stop
      @playbin.uri = "file://#{file}"
      notify_watchers :playfile, file
    end

    def play
      @playbin.play
    end

    def loop
      @loop = GLib::MainLoop.new(nil, false)
      @loop.run
    end
    
    def quit
      @playbin.stop
      @loop.quit
    end
  end
end
