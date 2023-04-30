require 'date'
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flammarion/version'


Gem::Specification.new do |s|
  s.name        = 'flammarion'
  s.version     = Flammarion::VERSION
  s.date        = Date.today
  s.summary     = 'Flammarion GUI Toolkit'
  s.description = 'The nifty Ruby gui toolkit. An easy to use gui toolkit built with scripting in mind.'
  s.authors     = ["Zach Capalbo"]
  s.email       = "zach.geek@gmail.com"
  s.files       = Dir["lib/**/*"] + %w[LICENSE Readme.md] + Dir["electron/*"]
  s.homepage    = 'https://github.com/zach-capalbo/flammarion'
  s.license     = 'MIT'
  s.add_runtime_dependency "rubame", "~> 0.0.2"
  s.add_runtime_dependency "colorize", "~> 0.7"
  s.add_runtime_dependency "filewatcher", "~> 0.5"
  s.add_runtime_dependency "launchy"
  s.add_runtime_dependency "websocket"
end
