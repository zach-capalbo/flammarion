require "bundler/gem_tasks"
require_relative 'lib/flammarion/version'

class CommandFailedError < StandardError; end
class VersionControlError < CommandFailedError; end

desc "Run html development server"
task :serve do
  Dir.chdir("lib/html") do
    system("middleman server")
  end
end

desc "Build all html/css/js files"
task :html do
  Dir.chdir("lib/html") do
    system("middleman build")
  end
end

task :build => [:html] do
  system("gem build flammarion.gemspec")
end

def new_version
  parts = Flammarion::VERSION.split(".")
  parts[2] = (parts[2].to_i + 1).to_s
  return parts.join(".")
end

def bump_version
  new_file = <<END
  module Flammarion
    VERSION = "#{new_version}"
  end
END
  File.write("#{File.dirname(__FILE__)}/lib/flammarion/version.rb", new_file)
end

desc "Increment #{Flammarion::VERSION} to #{new_version}"
task :bump_version do
  bump_version
end

desc "Build and push to rubgems"
task :publish => [:build] do
  raise VersionControlError.new("Uncommited Changes!") if `hg id`.include?("+")
  system("hg tag v#{Flammarion::VERSION}")
  system("gem push flammarion-#{Flammarion::VERSION}.gem")
  bump_version
  system("sudo gem install flammarion-#{Flammarion::VERSION}.gem")
  system("hg push")
end
