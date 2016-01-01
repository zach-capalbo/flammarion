#!/usr/bin/env ruby
#
# Service Example
#
# A simple example that lists the services on the system with buttons to start
# and stop them. Uses the `service` command to interace with services.
require_relative '../lib/flammarion'
require 'colorize'
require 'ostruct'

# First a list of all the services running on the system
services = `service --status-all`.split("\n").map{|l| m = l.match(/ \[ (.) \]\s*(\w+)/); o = OpenStruct.new; o.status = m[1]; o.name = m[2]; o }

# Now create a new engraving to display all this
f = Flammarion::Engraving.new(exit_on_disconnect:true)

# Now show everything in a table:
f.table(

  # Headers for readability. Flammarion can handle standard ANSI colors just fine.
  [["Status", "Service"].map{|h|h.light_magenta}] +
  services.collect do |service|

    # Create buttons which we can embed in the text. When they are clicked, the
    # blocks will be called.
    start_button = f.embedded_button("Start") { f.status "Starting #{service.name}"; system("service start #{service.name}"); f.status "Started #{service.name}".green}
    stop_button = f.embedded_button("Stop") { f.status "Stopping #{service.name}"; system("service stop #{service.name}"); f.status "Stopped #{service.name}".green}
    [service.status, service.name, start_button, stop_button]
  end, escape_html:false)

f.wait_until_closed
