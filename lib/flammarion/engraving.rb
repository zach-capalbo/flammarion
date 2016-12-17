module Flammarion

  # The engraving class represents a window. It contains everything you need to
  # display on the screen and interacts with a user. An {Engraving} contains
  # one or more panes, which are containers for writeable areas. Most of the
  # power of the panes comes from the {Writeable} module, which is also included
  # in {Engraving} (operating on the default pane) for convenience.
  # @see Writeable
  # @note Right now, there is no persistence of Engravings. Once it is closed,
  #   everything is erased, and you'll need to set it up all over again.
  # @note If you try to display something to a closed window, it will open a new
  #   blank window, and then display that thing.
  class Engraving
    include Revelator
    attr_accessor :on_disconnect, :on_callback_exception, :on_connect, :actions
    attr_accessor :callbacks, :sockets # @api private
    include Writeable

    # Creates a new Engraving (i.e., a new display window)
    # @option options [Proc] :on_connect Called when the display window is
    #  connected (i.e., displayed)
    # @option options [Proc] :on_disconnect Called when the display windows is
    #  disconnected (i.e., closed)
    # @option options [Proc] :on_callback_exception Called when there is an
    #  exception executing a provided callback. (e.g., so you can log it)
    #  If no handler is provided, Flammarion will attempt to pass the exception
    #  back to the original calling thread.
    # @option options [Boolean] :exit_on_disconnect (false) Will call +exit+
    #  when the widow is closed if this option is true.
    # @option options [Boolean] :close_on_exit (false) Will close the window
    #  when the process exits if this is true. Otherwise, it will just stay
    #  around, but not actually be interactive.
    # @option options [String] :title The initial title of the engraving. If
    #  empty, a random title will be generated.
    # @raise {SetupError} if neither chrome nor electron is set up correctly and
    #  and Flammarion is unable to display the engraving.
    def initialize(options = {})
      options = {:title => options} if options.is_a?(String)
      @chrome = OpenStruct.new
      @sockets = []
      @actions = {}
      @engraving = self
      @pane_name = "default"
      @on_connect = options[:on_connect]
      @on_disconnect = options[:on_disconnect]
      @on_callback_exception = options[:on_callback_exception]
      @exit_on_disconnect = options.fetch(:exit_on_disconnect, false)

      start_server
      @window_id = @@server.register_window(self)
      open_a_window(options) unless options[:no_window]
      @callbacks = {}
      wait_for_a_connection unless options[:no_wait]

      at_exit {close if window_open?} if options.fetch(:close_on_exit, true)

      title options[:title] if options[:title]
    end

    # Blocks the current thread until the window has been closed. All user
    # interactions and callbacks will continue in other threads.
    def wait_until_closed
      sleep 1 until @sockets.empty?
    end

    # Is this Engraving displayed on the screen.
    def window_open?
      not @sockets.empty?
    end

    # Pops up an alert message containing +text+.
    def alert(text)
      send_json(action:'alert', text:text)
    end

    # Changes the orientation of the panes in this engraving. Options are
    # - :horizontal
    # - :vertical
    def orientation=(orientation)
      raise ArgumentError.new("Orientation must be :horizontal or :vertical") unless [:horizontal, :vertical].include?(orientation)
      send_json({action:'reorient', orientation:orientation})
    end

    # Sets the title of the window
    def title(str)
      send_json({action:'title', title:str})
    end

    # Attempts to close the window.
    def close
      send_json({action:'close'})
    end

    # Opens a native "Save File" Dialog box, prompting the user for a file.
    def get_save_path
      if Gem.win_platform?
        `powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.SaveFileDialog;$f.InitialDirectory='%cd%';$f.Filter='All Files (*.*)|*.*';$f.showHelp=$true;$f.ShowDialog()|Out-Null;$f.FileName"`.strip
      else
        `zenity --file-selection --save --confirm-overwrite`.strip
      end
    end

    # Currently only works with Electron. Returns a PNG image of the Engraving
    def snapshot(&block)
      if block_given?
        id = make_id
        callbacks[id] = Proc.new {|d| block.call(d.fetch('data', {}).fetch('data', []).pack('c*')) }
        send_json(action:'snapshot', id: id)
      else
        return_value = nil
        snapshot {|d| return_value = d}
        Timeout.timeout(10) do
          sleep(0.01) until return_value
        end
        return return_value
      end
    end

    # Allows you to load a custom layout file. This replaces all html in the
    # window with a custom slim layout. You probably don't want this unless your
    # writing a very complex application.
    def layout(file)
      data = Slim::Template.new(file).render
      send_json({action:'layout', data:data})
    end

    def live_reload_layout(file)
      layout(file); yield if block_given?
      FileWatcher.new(file).watch {|file| layout(file); yield if block_given? }
    end

    # @api private
    def disconnect(ws)
      @sockets.delete ws
      exit 0 if @exit_on_disconnect
      @on_disconnect.call if @on_disconnect
    end

    # @api private
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
    rescue Exception
      if @on_callback_exception then
        @on_callback_exception.call($!)
      else
        raise
      end
    end

    # @api private
    def make_id
      @id ||= 0
      @id += 1
      "i#{@id}"
    end

    # @api private
    def start_server
      @@server ||= Server.new
    end

    # @api private
    def server; @@server; end;

    # @api private
    def send_json(val)
      if @sockets.empty? then
        open_a_window
        wait_for_a_connection
      end
      @sockets.each{|ws| ws.send val.to_json}
      nil
    end
  end
end
