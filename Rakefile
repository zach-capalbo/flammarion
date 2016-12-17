require_relative 'lib/flammarion/version'

class CommandFailedError < StandardError; end
class VersionControlError < CommandFailedError; end

desc "Run html development server"
task :serve do
  Dir.chdir("lib/html") do
    system("rm -r source/images/emoji/*")
    system("middleman server")
  end
end

task :server => [:serve] do
end

desc "Build all html/css/js files"
task :html => [:emoji] do
  Dir.chdir("lib/html") do
    system("middleman build")
  end
end

desc "Compile electron javascript"
task :electron do
  system("coffee -c electron/")
end

task :build => [:html, :electron] do
  system("gem build flammarion.gemspec")
end

def new_version
  parts = Flammarion::VERSION.split(".")
  parts[1] = (parts[1].to_i + 1).to_s
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

task :documentation do
  system("yardoc")
  rm_r "../../html/flammarion/doc"
  mv "doc", "../../html/flammarion"
  system("cp snapshots/* ../../html/flammarion/img")
  Dir.chdir("../../html/flammarion") do
    system(%|slimrb index.slim --trace -r 'redcarpet' -r 'rouge' -r 'rouge/plugins/redcarpet' > index.html|)
    system("git add doc")
    system("git commit -a -m 'Updated Documentation'")
    system("git push")
  end
end

task :bin_utils do
  FileUtils.mkdir_p 'bin'
  Dir["examples/*.rb"].each do |example|
    text = File.read(example).sub(%|require_relative '../lib/flammarion'|, %|require 'flammarion'|)
    dest = "bin/#{File.basename(example, '.rb')}"
    File.write(dest,text)
    chmod 0755, dest
  end
end

task :utils => [:bin_utils] do
  system("gem build flammarion-utils.gemspec")
end

desc "Build and push to rubgems"
task :publish => [:build, :documentation, :utils] do
  raise VersionControlError.new("Uncommited Changes!") unless system("git diff --quiet HEAD")
  system("git tag v#{Flammarion::VERSION}")
  system("gem push flammarion-#{Flammarion::VERSION}.gem")
  system("gem push flammarion-utils-#{Flammarion::VERSION}.gem")
  bump_version unless Flammarion::VERSION.include?("pre")
  system("sudo gem install flammarion-#{Flammarion::VERSION}.gem")
  system("sudo gem install flammarion-utils-#{Flammarion::VERSION}.gem")
  system("git push")
  system("git push --tags")
end

desc "Install Emoji Assets"
task :emoji do
  require 'gemojione'
  #next warn "Gemojione.index does not respond to images_path. Emoji will be disabled :(" unless Gemojione.index.respond_to?(:images_path)
  target = File.join(File.dirname(__FILE__), "lib/html/source/images/emoji")
  source = Gemojione.images_path
  FileUtils.mkdir_p target
  Dir["#{source}/*.png"].each do |png|
    FileUtils.cp(png, "#{target}/#{File.basename(png).downcase}")
  end

  # Update font awesome json
  fa_list = File.read(File.join(File.dirname(__FILE__), "lib/html/source/stylesheets/font-awesome/css/font-awesome.css")).each_line.collect{|l| l.scan(/fa-([a-z\-]+):before/)[0]}.reject{|n| n.nil?}.flatten.to_json
  File.write(File.join(File.dirname(__FILE__), "lib/html/source/javascripts/fontawesome.js"), "window.font_awesome_list = #{fa_list};")
end

task :pre => [:pre_version, :build] do
end
