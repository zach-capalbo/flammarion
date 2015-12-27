#!/usr/bin/env ruby

# Repl Example
#
# A simple interactive example for running a repl in flammarion
require_relative '../lib/flammarion'

class FlammarionRepl
  def initialize
    @f = Flammarion::Engraving.new(exit_on_disconnect:true)
    @f.subpane("output")
    @f.input("> ", autoclear:true, history:true) {|msg| repl(msg['text']) }
  end

  def repl(str)
    @f.subpane("output").puts "> #{str}"
    result =
      begin
        eval(str).to_s.green
      rescue Exception => e
        "#{e}".red
      end
    @f.subpane("output").puts result
  end

  def puts(str)
    @f.subpane("output").puts "#{str}"
  end
end

module Kernel
  def puts(str)
    $repl.puts(str)
  end
end

if __FILE__ == $0 then
  $repl = FlammarionRepl.new
  sleep 1000 while true
end
