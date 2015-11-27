#!/usr/bin/env ruby

# Engrave Example
#
# A simple example that will print ARGF to a flammarion engraving

require 'flammarion'

f = Flammarion::Engraving.new(exit_on_disconnect:true)

ARGF.each_line do |l|
  f.print l
end
sleep 0.5
