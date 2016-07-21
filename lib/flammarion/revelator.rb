require 'ostruct'
require 'launchy'
require 'timeout'

module Flammarion
  # Raised when flammarion cannot find any way to display an engraving.
  # On Linux, Flammarion will first try to launch Electron using the command
  # +electron+. If that fails, it will try common aliases of Google Chrome. If
  # none of them execute succesfully, it will raise this error. On Windows, it
  # will try to launch Google Chrome from Program Files (x86). If chrome has
  # been installed somewhere else, the user can set the environment variable
  # FLAMMARION_REVELATOR_PATH to point to +chrome.exe+.
  # @see http://electron.atom.io/
  # @see http://www.google.com/chrome/
  class SetupError < StandardError; end

  # @api private
  # @todo This all needs a lot of clean up
  module Revelator
    CHROME_PATH = ENV["FLAMMARION_REVELATOR_PATH"] || 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'

    def open_a_window(options = {})
      if RbConfig::CONFIG["host_os"] =~ /cygwin|mswin|mingw/
        development_mode = ENV["FLAMMARION_DEVELOPMENT"] == "true"
      else
        development_mode = system("lsof -i:#{4567}", out: '/dev/null') and File.exist?("#{File.dirname(__FILE__)}/../html/source/index.html.slim")
      end
      host = "file://#{File.dirname(File.absolute_path(__FILE__))}/../html/build/index.html"
      host = "http://localhost:4567/" if development_mode

      @expect_title = options[:title] || "Flammarion-#{rand.to_s[2..-1]}"
      url = "#{host}?path=#{@window_id}&port=#{server.port}&title=#{@expect_title}"
      @browser_options = options.merge({url: url, development_mode: development_mode})
      @requested_browser = ENV["FLAMMARION_BROWSER"] || options[:browser]

      @browser = @@browsers.find do |browser|
        next if @requested_browser and browser.name.to_s != @requested_browser
        begin
          __send__(browser.name, @browser_options)
        rescue Exception
          next
        end
      end

      raise SetupError.new("You must have either electron or google-chrome installed and accesible via your path.") unless @browser
    end

    # @api private
    def wait_for_a_connection
       Timeout.timeout(20) { sleep 0.5 while @sockets.empty? }
     rescue Timeout::Error
       raise SetupError.new("Timed out while waiting for a connecting using #{@browser.name}.")
    end

    private
    @@browsers = []
    def self.browser(name, &block)
      @@browsers << OpenStruct.new(name: name, method:define_method(name, block))
    end

    browser :chrome_windows do |options|
      return false unless RbConfig::CONFIG["host_os"] =~ /cygwin|mswin|mingw/
      file_path = File.absolute_path(File.join(File.dirname(__FILE__), ".."))
      file_path = `cygpath -w '#{file_path}'`.strip if RbConfig::CONFIG["host_os"] == "cygwin"
      resource = %[file\://#{file_path}/html/build/index.html]
      resource = "http://localhost:4567/" if options[:development_mode]
      chrome_path = CHROME_PATH
      chrome_path = `cygpath -u '#{CHROME_PATH}'`.strip if RbConfig::CONFIG["host_os"] == "cygwin"
      return false unless File.exist?(chrome_path)
      Process.detach(spawn(chrome_path, %[--app=#{resource}?path=#{@window_id}&port=#{server.port}&title="#{options[:title] || "Flammarion%20Engraving"}"]))
    end

    browser :osx do |options|
      return false unless RbConfig::CONFIG["host_os"] =~ /darwin|mac os/
      executable = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      @chrome.in, @chrome.out, @chrome.err, @chrome.thread = Open3.popen3("'#{executable}' --app='#{options[:url]}'")
      return true if @chrome.in
    end

    browser :electron do |options|
      if which('electron') then
        Process.detach(spawn("electron #{File.dirname(File.absolute_path(__FILE__))}/../../electron '#{options[:url]}' #{options[:width]} #{options[:height]}"))
        return true
      end
      false
    end

    browser :chrome do |options|
      %w[google-chrome google-chrome-stable chromium chromium-browser chrome].each do |executable|
        next unless which(executable)
        @chrome.in, @chrome.out, @chrome.err, @chrome.thread = Open3.popen3("#{executable} --app='#{options[:url]}'")
        return true if @chrome.in
      end
      return false
    end

    browser :www do |options|
      # Last ditch effort to display something
      Launchy.open(options[:url].gsub(/\s/, "%20")) do |error|
        return false
      end
      return true
    end

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
  end
end
