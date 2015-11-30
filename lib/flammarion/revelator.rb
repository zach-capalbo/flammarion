module Flammarion
  module Revelator
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

    CHROME_PATH = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
    def open_a_window_on_windows
      file_path = File.absolute_path(File.join(File.dirname(__FILE__), ".."))
      file_path = `cygpath -w '#{file_path}'`.strip if RbConfig::CONFIG["host_os"] == "cygwin"
      resource = %[file\://#{file_path}/html/build/index.html]
      chrome_path = CHROME_PATH
      chrome_path = `cygpath -u '#{CHROME_PATH}'`.strip if RbConfig::CONFIG["host_os"] == "cygwin"
      spawn(chrome_path, %[--app=#{resource}?path=#{@window_id}&port=#{server.port}])
    end

    def open_a_window
      return open_a_window_on_windows if RbConfig::CONFIG["host_os"] =~ /cygwin|mswin|mingw/
      developmentMode = system("lsof -i:#{4567}", out: '/dev/null')
      host = "file://#{File.dirname(File.absolute_path(__FILE__))}/../html/build/index.html"
      host = "http://localhost:4567/" if developmentMode

      # data_dir = Dir.mktmpdir("flammarion")
      # File.open("#{data_dir}/First\ Run", "w") {}

      @expect_title = "Flammarion-#{rand.to_s[2..-1]}"

      if which('electron') then
        Process.detach(spawn("electron #{File.dirname(File.absolute_path(__FILE__))}/../../electron '#{host}?path=#{@window_id}&port=#{server.port}&title=#{@expect_title}'"))
        return
      end

      %w[google-chrome google-chrome-stable chromium chromium-browser chrome C:\Program\ Files\ (x86)\Google\Chrome\Application\chrome.exe].each do |executable|
        @chrome.in, @chrome.out, @chrome.err, @chrome.thread = Open3.popen3("#{executable} --app='#{host}?path=#{@window_id}&port=#{server.port}&title=#{@expect_title}'")
        break if @chrome.in
      end

      raise StandardError.new("Cannot launch any browser") unless @chrome.in
    end
  end
end
