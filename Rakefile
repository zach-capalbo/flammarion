require "bundler/gem_tasks"
require_relative 'lib/flammarion/version'

class CommandFailedError < StandardError; end
class VersionControlError < CommandFailedError; end

task :serve do
  Dir.chdir("lib/html") do
    system("middleman server")
  end
end

task :html do
  Dir.chdir("lib/html") do
    system("middleman build")
  end
end

task :build => [:html] do
  system("gem build flammarion.gemspec")
end

def bump_version
  parts = Flammarion::VERSION.split(".")
  parts[2] = (parts[2].to_i + 1).to_s
  new_file = <<END
  module Flammarion
    VERSION = "#{new_version}"
  end
END
  File.write('lib/flammarion')
end

task :bump_version do
  bump_version
end

task :publish => [:build] do
  raise VersionControlError.new("Uncommited Changes!") if `hg id`.include?("+")
  system("hg tag v#{Flammarion::VERSION}")
  system("gem push flammarion-#{Flammarion::VERSION}.gem")
  system("sudo gem install flammarion-#{Flammarion::VERSION}.gem")
  bump_version
  system("hg push")
end
