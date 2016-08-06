#!/usr/bin/env ruby

# Engrave Example
#
# A simple example that will print ARGF to a flammarion engraving

require_relative '../lib/flammarion'

f = Flammarion::Engraving.new(title:ARGF.filename, exit_on_disconnect:true)
f.status("Flammarion version: #{Flammarion::VERSION.green}", :right)

ARGF.each_line do |l|
  f.print l
end

f.wait_until_closed
