#!/usr/bin/env ruby

# Emoji Keyboard Example
#
# A simple example that will output the selected emoji to STDOUT and a also to
# a seperate pane.

require_relative '../lib/flammarion'

f = Flammarion::Engraving.new
f.style "font-size", "200%"
f.pane("output", weight: 0.1).send("> ")
f.emoji.keys.each do |emoji|
  f.button(emoji, escape_icons: true, inline: true) do
    unicode_char = f.emoji[emoji]['unicode'].last.split("-").map(&:hex).pack("U")
    f.pane("output").send unicode_char
    print unicode_char
  end
end

f.wait_until_closed
