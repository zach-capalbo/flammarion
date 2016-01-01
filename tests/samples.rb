require_relative "../lib/flammarion.rb"
require 'faker'

unless defined?("sample")
def sample(name)
  return if ARGV[0] and name.to_s != ARGV[0]
  puts "Showing: #{name}"
  f = Flammarion::Engraving.new(title:name.to_s.split("_").collect{|w| w[0] = w[0].upcase; w}.join(" "))
  yield(f)
  f.wait_until_closed
end
end

sample :message_sender_with_contacts do |f|
  f.orientation = :horizontal
  f.subpane("number").input("Phone Number")
  f.checkbox("Request Read Receipt")
  f.input("Body", multiline:true)
  f.button("Send") {f.status("Error: #{ArgumentError.new("Dummy Error")}".red)}
  f.pane("contacts", weight:0.7).puts("Contacts", replace:true)
  icons = %w[thumbs-up meh-o bicycle gears star-o star] + [nil] * 5
  30.times do |i|
    right_icon = icons.sample
    left_icon = icons.sample
    name = Faker::Name.name
    f.pane("contacts").button(name, right_icon:right_icon, left_icon: left_icon) do
      f.subpane("number").replace("To: #{name.light_magenta}")
    end
  end
end

sample :table_with_side_panes do |f|
  f.orientation = :horizontal
  f.table( 20.times.map do |i|
    [i, Faker::Name.name, Faker::Address.street_address]
  end, headers: ["Id", "Name", "Address"].map{|h| h.light_magenta})
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
    end, style:{'float' => 'left'})
  end
end

sample :sine_wave_plot do |f|
  data = 100.times.collect {|x| Math.sin(x / 100.0 * 5.0 * Math::PI)}
  f.plot(data)
end
