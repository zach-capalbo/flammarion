require "bundler/gem_tasks"

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
end
