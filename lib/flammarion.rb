require 'open3'
require 'ostruct'
require 'em-websocket'
require 'json'
require 'colorize'
require 'filewatcher'
require 'rbconfig'

# Optional requires
require 'sass'
require 'slim'
require 'coffee-script'
require 'redcarpet'

require_relative 'flammarion/writeable.rb'
require_relative 'flammarion/pane.rb'
require_relative 'flammarion/server.rb'
require_relative 'flammarion/version.rb'
require_relative 'flammarion/revelator.rb'
require_relative 'flammarion/about.rb'

module Flammarion
  class Engraving
    include Revelator
    attr_reader :chrome
    attr_accessor :callbacks, :sockets, :on_disconnect, :on_connect, :actions
    include Writeable

    # Creates a new Engraving (i.e., a new display window)
    # @option options [Proc] :on_connect Called when the display window is
    #  connected (i.e., displayed)
    # @option options [Proc] :on_disconnect Called when the display windows is
    #   disconnected (i.e., closed)
    def initialize(options = {})
      @chrome = OpenStruct.new
      @sockets = []
      @actions = {}
      @front_end = self
      @pane_name = "default"
      @on_connect = options[:on_connect]
      @on_disconnect = options[:on_disconnect]
      @exit_on_disconnect = options.fetch(:exit_on_disconnect, false)

      start_server
      @window_id = @@server.register_window(self)
      open_a_window unless options[:no_chrome]
      @callbacks = {}
      wait_for_a_connection unless options[:no_wait]

      at_exit {close} if options.fetch(:close_on_exit, false)
    end

    def disconnect(ws)
      @sockets.delete ws
      exit 0 if @exit_on_disconnect
      @on_disconnect.call if @on_disconnect
    end

    def wait_until_closed
      sleep 1 until @sockets.empty?
    end

    def process_message(msg)
      @last_msg = msg
      m = {}
      begin
        m = JSON.parse(msg)
      rescue JSON::ParserError
        log "Invalid JSON String"
        return
      end

      case m["action"]
      when 'callback'
        callback = @callbacks[m['id']]
        unless callback.nil?
          if callback.arity == 1
            callback.call(m)
          else
            callback.call
          end
        end
      end
      @actions[m["action"]].call(m) if @actions.include?(m["action"])
    end

    def make_id
      @id ||= 0
      @id += 1
      "i#{@id}"
    end

    def start_server
      @@server ||= Server.new
    end

    def server; @@server; end;

    def wait_for_a_connection
      sleep 0.5 while @sockets.empty?
    end

    def window_open?
      not @sockets.empty?
    end

    def send_json(val)
      if @sockets.empty? then
        open_a_window
        wait_for_a_connection
      end
      @sockets.each{|ws| ws.send val.to_json}
      nil
    end

    def alert(text)
      send_json(action:'alert', text:text)
    end

    def orientation=(orientation)
      raise ArgumentError.new("Orientation must be :horizontal or :vertical") unless [:horizontal, :vertical].include?(orientation)
      send_json({action:'reorient', orientation:orientation})
    end

    def title(str)
      send_json({action:'title', title:str})
    end

    def layout(file)
      data = Slim::Template.new(file).render
      send_json({action:'layout', data:data})
    end

    def close
      send_json({action:'close'})
    end

    def live_reload_layout(file)
      layout(file); yield if block_given?
      FileWatcher.new(file).watch {|file| layout(file); yield if block_given? }
    end

    def get_save_path
      if Gem.win_platform?
        `powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.SaveFileDialog;$f.InitialDirectory='%cd%';$f.Filter='All Files (*.*)|*.*';$f.showHelp=$true;$f.ShowDialog()|Out-Null;$f.FileName"`.strip
      else
        `zenity --file-selection --save --confirm-overwrite`.strip
      end
    end
  end
end
