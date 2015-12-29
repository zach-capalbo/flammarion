require 'open3'
require 'ostruct'
require 'em-websocket'
require 'json'
require 'colorize'
require 'filewatcher'
require 'rbconfig'

begin
  # Optional Requires
  require 'sass'
  require 'slim'
  require 'coffee-script'
  require 'redcarpet'
rescue LoadError
end

require_relative 'flammarion/writeable.rb'
require_relative 'flammarion/pane.rb'
require_relative 'flammarion/server.rb'
require_relative 'flammarion/version.rb'
require_relative 'flammarion/revelator.rb'
require_relative 'flammarion/about.rb'
require_relative 'flammarion/engraving.rb'

module Flammarion
end
