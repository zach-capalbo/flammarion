require 'open3'
require 'ostruct'
require 'json'
require 'colorize'
require 'filewatcher'
require 'rbconfig'
require_relative 'rubame/rubame.rb'

begin
  # Optional Requires
  require 'sass'
  require 'slim'
  require 'coffee-script'
  require 'kramdown' unless defined?(Redcarpet::Markdown)
rescue LoadError
end

require_relative 'flammarion/plot.rb'
require_relative 'flammarion/writeable.rb'
require_relative 'flammarion/pane.rb'
require_relative 'flammarion/server.rb'
require_relative 'flammarion/version.rb'
require_relative 'flammarion/revelator.rb'
require_relative 'flammarion/about.rb'
require_relative 'flammarion/engraving.rb'

# This is the main namespace for Flammarion. You really need an {Engraving} to
# do anything useful. If you just want to test that everything is setup
# correctly, you can use {Flammarion.about}. You can find samples and
# screenshots at https://github.com/zach-capalbo/flammarion and some examples
# at https://github.com/zach-capalbo/flammarion/tree/master/examples
# @see Engraving
# @see Writeable
# @see https://github.com/zach-capalbo/flammarion
# @see https://github.com/zach-capalbo/flammarion/tree/master/examples
module Flammarion
end
