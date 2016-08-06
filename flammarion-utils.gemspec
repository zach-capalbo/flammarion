lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flammarion/version'


Gem::Specification.new do |s|
  s.name        = 'flammarion-utils'
  s.version     = Flammarion::VERSION
  s.date        = Date.today
  s.summary     = 'Tools from the Flammarion GUI Toolkit'
  s.description = 'Extra tools using the Flammarion toolkit.'
  s.authors     = ["Zach Capalbo"]
  s.email       = "zach.geek@gmail.com"

  # Note: This gets created by the Rakefile from the exmaples files.
  s.files       = %w[LICENSE Readme.md] + Dir["bin/*"]
  s.bindir      = "bin"
  s.executables = Dir["bin/*"].map{|f| File.basename(f)}
  s.homepage    = 'https://github.com/zach-capalbo/flammarion'
  s.license     = 'MIT'
  s.add_runtime_dependency "flammarion", "= #{Flammarion::VERSION}"
end
