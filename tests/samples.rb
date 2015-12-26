require_relative "../lib/flammarion.rb"
require 'faker'
require 'optparse'

def sample(name)
  return if ARGV[0] and name.to_s != ARGV[0]
  puts "Showing: #{name}"
  f = Flammarion::Engraving.new
  f.title(name.to_s.split("_").collect{|w| w[0] = w[0].upcase; w}.join(" "))
  yield(f)
  f.wait_until_closed
end

sample :message_sender_with_contacts do |f|
  f.orientation = :horizontal
  f.subpane("number").input("Phone Number")
  f.input("Body", multiline:true)
  f.button("Send") {f.status("Error: #{ArgumentError.new("Dummy Error")}".red)}
  f.pane("contacts", weight:0.7).puts("Contacts", replace:true)
  icons = %w[thumbs-up meh-o bicycle gears star-o star] + [nil] * 5
  30.times do |i|
    right_icon = icons.sample
    left_icon = icons.sample
    f.pane("contacts").button(Faker::Name.name, right_icon:right_icon, left_icon: left_icon)
  end
end

sample :table_with_side_panes do |f|
  f.orientation = :horizontal
  f.table([["Id", "Name", "Address"].map{|h| h.light_magenta}] + 20.times.map do |i|
    [i, Faker::Name.name, Faker::Address.street_address]
  end)
  f.pane("sidebar").pane("side1").puts Faker::Hipster.paragraph.red
  f.pane("sidebar").pane("side2").puts Faker::Hipster.paragraph.green

  3.times { f.status(Faker::Hipster.sentence.light_green)}
end

sample :log_viewer do |f|
  f.button_box("b").button("Clear", right_icon:'trash-o') {f.subpane('s').clear}
  f.button_box("b").button("w-w") { f.subpane('s').style('word-wrap', 'initial')}
  20.times { f.subpane('s', fill:true).puts(Faker::Hipster.paragraph) }
end

sample :readme do |f|
  f.orientation = :horizontal
  f.markdown(File.read("#{File.dirname(__FILE__)}/../Readme.md"))
  f.pane("code").highlight(File.read(__FILE__))
end

sample :colors do |f|
  colors = %w[black red green yellow blue magenta cyan white]
  ([:none] + colors + colors.collect{|b| "light_#{b}"}).each do |bg|
    f.table(colors.collect do|c|
      [c.colorize(:color => c.to_sym, :background => bg.to_sym),
        "light_#{c}".colorize(:color => "light_#{c}".to_sym, :background => bg.to_sym)]
    end)
  end
end
