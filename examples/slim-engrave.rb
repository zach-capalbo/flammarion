#!/usr/bin/env ruby
require_relative '../lib/flammarion'

f = Flammarion::Engraving.new(ARGV[0])

begin
  f.live_reload_layout(ARGV[0])
rescue Exception
  f.replace "#{$!}\n#{$!.backtrance.join("\n")}"
  sleep(1)
  retry
end
