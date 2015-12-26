#!/usr/bin/env ruby
#
# A simple example that will wrap any command into a flammarion window.
require 'open3'
require 'flammarion'

f = Flammarion::Engraving.new(exit_on_disconnect:true)
i, o, e, t = Open3.popen3(*ARGV.to_a)

f.subpane("out").print("")

f.subpane("in").input("> ", autoclear:true) do |msg|
  i.puts msg['text']
end

f.subpane("in").button("Close (Ctrl+D)") do
  f.subpane("in").clear
  i.close
  t.value.success? ? f.status("Exit Success".light_green) : f.status("Exit code: #{t.value}".light_red)
end

Thread.new do
  while l = e.readpartial(4096)
    f.subpane("out").print l.red
  end
end

begin
  while l = o.readpartial(4096)
    f.subpane("out").print l
  end
rescue EOFError
  f.subpane("in").clear
  t.value.success? ? f.status("Exit Success".light_green) : f.status("Exit code: #{t.value}".light_red)
end

f.wait_until_closed
