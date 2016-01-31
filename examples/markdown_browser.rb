#!/usr/bin/env ruby
require_relative '../lib/flammarion'

pwd = Dir.pwd
f = Flammarion::Engraving.new(title:pwd)
f.orientation = :horizontal
f.markdown("Choose a file ->")
f.pane("files", weight:0.3)

(Dir["**/*.md"] + Dir["**/*.markdown"]).each do |file|
  f.pane("files", weight:0.3).button(file) do
    f.markdown(File.read(file), replace:true)
  end
end

f.wait_until_closed
