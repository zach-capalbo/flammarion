module Flammarion
  # @api private
  class Server
    attr_reader :port
    def initialize
      @windows = {}
      @socket_paths = {}
      @started = false
      Thread.new do
        begin
          start_server_internal
        rescue SystemExit
          raise
        rescue Exception => e
          if binding.respond_to? :pry
            binding.pry
          else
            raise
          end
        end
      end
      sleep 0.5 while not @started

      # This is a hack. For some reason, you need to wait a bit for everything
      # to get written.
      at_exit { sleep 0.1 }
    end
    def start_server_internal
      @port = 7870
      @port = rand(65000 - 1024) + 1024 if Gem.win_platform?
      begin
        @server = Rubame::Server.new("0.0.0.0", @port)
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
                rescue Exception => e
                  Kernel.puts "#{e.message.to_s.red}\n#{e.backtrace.join("\n").light_red}"
                  if binding.respond_to? :pry
                    binding.pry
                  else
                    raise
                  end
                end
              end
            }
          end
        end
      rescue RuntimeError => e
        if e.message == "no acceptor (port is in use or requires root privileges)"
          @port = rand(65000 - 1024) + 1024
          retry
        else
          raise
        end
      end
      @started = true
    rescue Exception => e
      unless e.is_a? SystemExit or e.is_a? Interrupt
        Kernel.puts "Error in server:"
        binding.pry if binding.respond_to? :pry
        Kernel.puts e.message
        Kernel.puts e.backtrace.inspect
      end
      raise
    end

    def stop
    end

    def log(str)
      # Kernel.puts str
    end

    def register_window(window)
      @new_path ||= 0
      @new_path += 1
      @windows["/w#{@new_path}"] = window
      return "w#{@new_path}"
    end
  end
end
