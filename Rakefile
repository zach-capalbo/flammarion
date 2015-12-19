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

task :publish => [:build] do
  raise VersionControlError.new("Uncommited Changes!") if `hg id`.include?("+")
  system("hg tag v#{Flammarion::VERSION}")
  system("gem push flammarion-#{Flammarion::VERSION}.gem")
  system("sudo gem install flammarion-#{Flammarion::VERSION}.gem")
  system("hg push")
end
