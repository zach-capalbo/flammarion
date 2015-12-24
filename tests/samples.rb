require_relative "../lib/flammarion.rb"
require 'faker'

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
  f.pane("contacts").puts("Contacts", replace:true)
  30.times do
    f.pane("contacts").button(Faker::Name.name)
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
