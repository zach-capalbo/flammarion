module Flammarion
  @@revelators = []
  module Revelator
    def open_a_window(revelator = nil)
      revelators.select{|r| r.is_valid?}.each do |r|
        begin
          return r.open_a_window
        rescue
          next
        end
      end
    end

    def revelators; return @@revelators; end

    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end
      return nil
    end

    class Chrome
      Revelator.revelators << self
      @@executables = %w[google-chrome google-chrome-stable chromium chromium-browser chrome]
      def is_valid?
        @@executables.find{|e| which(e)}
      end
      def open_a_window
      end
    end
  end
end
