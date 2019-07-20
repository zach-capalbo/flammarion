module Flammarion
  # @api private
  class Server
    attr_reader :port, :server_thread
    def initialize
      @windows = {}
      @socket_paths = {}
      @started = false
      @launch_thread = Thread.current
      @server_thread = Thread.new do
        begin
          start_server_internal
        rescue StandardError
          handle_exception($!)
        end
      end
      sleep 0.01 while not @started
    end

    def wsl_platform
      return File.file?('/proc/version') &&
        File.open('/proc/version', &:gets).downcase.include?("microsoft")
    end

    def start_server_internal
      @port = 7870
      @port = rand(65000 - 1024) + 1024 if Gem.win_platform? || wsl_platform

      begin
        @server = Rubame::Server.new("0.0.0.0", @port)
        log "WebServer started on port #{@port}"
        while true do
          @started = true
          @server.run do |ws|
            ws.onopen {
              log "WebSocket connection open"
              if @windows.include?(ws.handshake.path)
                @windows[ws.handshake.path].sockets << ws
                @windows[ws.handshake.path].on_connect.call() if @windows[ws.handshake.path].on_connect
                @socket_paths[ws] = ws.handshake.path
              else
                log "No such window: #{handshake.path}"
              end
            }

            ws.onclose do
              log "Connection closed";
              @windows[@socket_paths[ws]].disconnect(ws) if @windows[@socket_paths[ws]]
            end

            ws.onmessage { |msg|
              Thread.new do
                begin
                  @windows[@socket_paths[ws]].process_message(msg)
                rescue Exception
                  handle_exception($!)
                end
              end
            }
          end
        end
      rescue RuntimeError, Errno::EADDRINUSE
        if $!.message == "no acceptor (port is in use or requires root privileges)" or $!.is_a? Errno::EADDRINUSE
          @port = rand(65000 - 1024) + 1024
          retry
        else
          raise
        end
      end
      @started = true
    end

    def stop
    end

    def log(str)
      # Kernel.puts str
    end

    def handle_exception(e)
      @launch_thread.raise(e)
    end

    def register_window(window)
      @new_path ||= 0
      @new_path += 1
      @windows["/w#{@new_path}"] = window
      return "w#{@new_path}"
    end
  end
end
