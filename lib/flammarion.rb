require 'monitor'
require 'open3'
require 'ostruct'
require 'em-websocket'
require 'json'
require 'slim'
require 'coffee-script'
require 'sass'
require 'colorize'
require 'filewatcher'

require_relative 'flammarion/writeable.rb'
require_relative 'flammarion/pane.rb'
require_relative 'flammarion/server.rb'

module Flammarion
  class Engraving
    attr_reader :chrome
    attr_accessor :callbacks, :sockets, :on_disconnect, :on_connect, :actions
    include Writeable
    def initialize(options = {})
      @chrome = OpenStruct.new
      @sockets = []
      @actions = {}
      @front_end = self
      @pane_name = "default"
      start_server
      @window_id = @@server.register_window(self)
      open_a_window unless options[:no_chrome]
      @callbacks = {}
      @exit_on_disconnect = options.fetch(:exit_on_disconnect, false)
      wait_for_a_connection unless options[:no_wait]
      @on_disconnect = options[:on_disconnect]
      @ignore_old = options.fetch(:ignore_old, false)
      @on_connect = options[:on_connect]
    end

    def disconnect(ws)
      @sockets.delete ws
      exit 0 if @exit_on_disconnect
      @on_disconnect.call if @on_disconnect
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

    def wait_for_a_connection
      sleep 0.5 while @sockets.empty?
    end

    CHROME_PATH = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
    def open_a_window_on_windows
      resource = %[file\://#{File.absolute_path(File.dirname(__FILE__))}/html/build/index.html]
      spawn(CHROME_PATH, %[--app=#{resource}?path=#{@window_id}&port=#{@@server.port}])
    end

    def open_a_window
      return open_a_window_on_windows if Gem.win_platform?
      developmentMode = system("lsof -i:#{4567}", out: '/dev/null')
      host = "file://#{File.dirname(File.absolute_path(__FILE__))}/html/build/index.html"
      host = "http://localhost:4567/" if developmentMode

      # data_dir = Dir.mktmpdir("flammarion")
      # File.open("#{data_dir}/First\ Run", "w") {}

      @expect_title = "Flammarion-#{rand.to_s[2..-1]}"

      %w[google-chrome google-chrome-stable chromium chromium-browser chrome C:\Program\ Files\ (x86)\Google\Chrome\Application\chrome.exe].each do |executable|
        @chrome.in, @chrome.out, @chrome.err, @chrome.thread = Open3.popen3("#{executable} --app='#{host}?path=#{@window_id}&port=#{@@server.port}&title=#{@expect_title}'")
        break if @chrome.in
      end

      raise StandardError.new("Cannot launch any browser") unless @chrome.in
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

    def pane(name)
      return Pane.new(self, name)
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
