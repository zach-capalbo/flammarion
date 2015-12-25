#!/usr/bin/env ruby
#
# frake.rb: Wraps a little gui around rake tasks

require_relative '../lib/flammarion.rb'
require 'open3'
f = Flammarion::Engraving.new(exit_on_disconnect:true)
f.title "frake #{Dir.pwd}"

def run(task)
  f2 = Flammarion::Engraving.new
  f2.title task
  f2.puts "Running #{task.light_magenta}"
  Open3.popen3(task) do |i,o,e,t|
    Thread.new {e.each_line{|l| f2.print l.red}}
    o.each_line {|l| f2.print l}
    f2.status t.value.success? ? "Done!".light_green : "Failed!".light_red
  end
end

f.markdown "# Rake Tasks: "
`rake -T`.each_line do |l|
  f.break
  parts = l.split("#")
  task = parts[0]
  desc = parts[1]
  f.puts desc
  f.button(task) do
    run(task)
  end
end

f.wait_until_closed
