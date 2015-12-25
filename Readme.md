# Flammarion GUI Toolkit

[![Gem Version](https://badge.fury.io/rb/flammarion.svg)](https://badge.fury.io/rb/flammarion)

## Overview

Flammarion is an easy-to-use library for displaying information that you might
normally display to the command line in a slightly easier-to-access way.

It is not intended to be a full fledged application development toolkit. It is
intended instead for small scripts where you just want to show some information
without going through too much trouble.

## Documentation

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

There's lots more, too. I'll write more documentation eventually.

## Installation

First you need to install [Google Chrome](https://www.google.com/chrome/browser/desktop/index.html)
and make sure it's in your path. Then you can install the gem:

`gem install flammarion`

or add it to your Gemfile.

## Behind the scenes

Flammarion uses Chrome to display a simple html page, and WebSockets to communicate
between the Javascript and ruby.

# Bundled Packages

Flammarion is distributed with a bunch of useful tools to make everyone's life easier.
They are:

 * [ansi up](https://github.com/drudru/ansi_up)
 * [highlihgt.js](https://highlightjs.org/)
 * [jquery](https://jquery.com/)
 * [jquery transit](http://ricostacruz.com/jquery.transit/)
 * [leaflet](http://leafletjs.com/)
 * [font awesome](https://fortawesome.github.io/Font-Awesome/)
