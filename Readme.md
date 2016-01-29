# Flammarion GUI Toolkit

[![Gem Version](https://badge.fury.io/rb/flammarion.svg)](https://badge.fury.io/rb/flammarion)

* [Source](https://github.com/zach-capalbo/flammarion)
* [Documentation](http://zach-capalbo.github.io/flammarion/doc/Flammarion.html)

## Overview

Flammarion is an easy-to-use library for displaying information that you might
normally display to the command line in a slightly easier-to-access way.

It is not intended to be a full fledged application development toolkit. It is
intended instead for small scripts where you just want to show some information
or buttons without going through too much trouble.

## Installation

First, you need to install [electron](http://electron.atom.io/) or [chrome](http://www.google.com/chrome)
and make sure it's in your path. (*Note:* On Windows, currently only chrome
works, but you don't need to worry about putting it in your path.)

Then you can install the gem:

```
gem install flammarion
```

or add it to your Gemfile.

## Tutorial

The easiest way to use Flammarion, is similar to how you might use STDOUT:

```ruby
require 'flammarion'
f = Flammarion::Engraving.new
f.puts "Hello World!"
```

It can even support standard console color codes: (Thanks to [ansi_up](http://github.com/drudru/ansi_up)!)

```ruby
require 'colorized'
f.puts "This line will be red!".red
f.puts "This #{"word".colorize(:green)} will not be blue."
```

However, you can also do more advanced things. Say you want to show a table. Easy!

```ruby
f.table(
  [%w[Number Squared Sqrt].map{|h| h.light_magenta}] + # Make the header a different color
  10.times.collect{|x| [x, x * x, Math.sqrt(x)]})
```

Or maybe you want to know where something is:

```ruby
f.map("Boston, MA")
```

Maybe you even want to see both of those things *at the same time*!

```ruby
f.pane("numberstuff").table([%w[Number Squared Sqrt].map{|h| h.light_magenta}] +
  10.times.collect{|x| [x, x * x, Math.sqrt(x)]})
f.pane("mapstuff").map("Big Ben")
```

If you need feedback, there's a simple callback mechanism for buttons and text
boxes:

```ruby
f.button("Click Here!!!") {f.puts "You clicked the button!"}
f.input("Placeholder > ") {|msg| f.puts "You wrote: #{msg['text'].light_magenta}"}
```

The [api documetaion](http://zach-capalbo.github.io/flammarion/doc/Flammarion.html)
is available at <http://zach-capalbo.github.io/flammarion/doc/Flammarion.html>.

## Screenshots / Samples

### Message Composer with Address Book

```ruby
f = Flammarion::Engraving.new
f.orientation = :horizontal
recipient = f.subpane("number").input("Phone Number")
text = f.input("Body", multiline:true)
f.button("Send") { send_message(recipient.to_s, text.to_s); f.status("Message Sent!")}
f.pane("contacts").puts("Contacts", replace:true)
icons = %w[thumbs-up meh-o bicycle gears star-o star] + [nil] * 5
30.times do |i|
  name = Faker::Name.name
  f.pane("contacts").button(name, right_icon:icons.sample, left_icon:icons.sample) do
    recipient = name
    f.subpane("number").replace(name)
  end
end
```

![Message Sample](http://zach-capalbo.github.io/flammarion/img/messagesample.png)

### Rake Task Runner

```ruby
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
```

![Frake](http://zach-capalbo.github.io/flammarion/img/frake.png)

### Tables

```ruby
f = Flammarion::Engraving.new
f.orientation = :horizontal
f.table([["Id", "Name", "Address"].map{|h| h.light_magenta}] + 20.times.map do |i|
  [i, Faker::Name.name, Faker::Address.street_address]
end)
f.pane("sidebar").pane("side1").puts Faker::Hipster.paragraph.red
f.pane("sidebar").pane("side2").puts Faker::Hipster.paragraph.green

3.times { f.status(Faker::Hipster.sentence.light_green)}
```

![Table Sample](http://zach-capalbo.github.io/flammarion/img/table.png)


## Examples

There are a number of useful examples in the [examples directory.](https://github.com/zach-capalbo/flammarion/tree/master/examples)

# Bundled Packages

Flammarion is distributed with a bunch of useful tools to make everyone's life easier.
They are:

 * [ansi up](https://github.com/drudru/ansi_up)
 * [highlihgt.js](https://highlightjs.org/)
 * [jquery](https://jquery.com/)
 * [jquery transit](http://ricostacruz.com/jquery.transit/)
 * [leaflet](http://leafletjs.com/)
 * [font awesome](https://fortawesome.github.io/Font-Awesome/)
