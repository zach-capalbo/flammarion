#!/usr/bin/env ruby
#
# Service Example
#
# A simple example that lists the services on the system with buttons to start
# and stop them.

require_relative '../lib/flammarion'
require 'colorize'
require 'ostruct'

# First a list of all the services running on the system
services = `service --status-all`.split("\n").map{|l| m = l.match(/ \[ (.) \]\s*(\w+)/); o = OpenStruct.new; o.status = m[1]; o.name = m[2]; o }

# Now create a new engraving to display all this
f = Flammarion::Engraving.new(exit_on_disconnect:true)

# Now show everything in a table:

f.table(
  [["Status", "Service"].map{|h|h.light_magenta}] + # Headers for readability
  services.collect do |service|
    start_button = f.embedded_button("Start") { puts "Starting #{service.name}"}
    stop_button = f.embedded_button("Stop") { puts "Stopping #{service.name}"}
    [service.status, service.name, start_button, stop_button]
  end, escape_html:false)
sleep 1000 while true
