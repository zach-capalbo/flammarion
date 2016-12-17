#!/usr/bin/env ruby
require_relative '../lib/flammarion'
require 'oga'

x = Oga.parse_xml(ARGF)

$f = Flammarion::Engraving.new
def f; $f; end;

def node_window; f.pane("nodewindow", weight: 0.85); end

def history_window; f.pane("history", weight: 0.15);end

history_window
node_window

f.orientation = :horizontal

f.pane("default").hide

module Oga
  module XML
    module  Traversal
      def element_children
        children.select{|c| c.is_a? Element}
      end
    end
    class Document
      def parent; self; end
      def attributes; []; end
      def name; "Document"; end
    end
  end
end

def add_history(node)
  history = [node]
  history << history.last.parent until history.last.parent.is_a? Oga::XML::Document
  history_window.clear
  history.reverse.each do |n|
    history_window.button("#{n.name} #{n.attributes.map(&:to_xml).join(" ")}") do
      display(n)
    end
  end
end

def add_button(n)
  node_window.subpane("buttons").button("#{n.name} #{n.attributes.map(&:to_xml).join(" ")}") do |c|
    display(n)
  end
end

def display(node)
  add_history(node)
  node_window.clear
  node_window.markdown("# #{node.name}")
  node_window.table node.attributes.map{|a| [a.name.to_s.light_magenta, a.value]}
  node_window.input("CSS", history:true) do |m|
    node_window.subpane("buttons").clear
    node.css(m['text']).each {|n| add_button(n) }
  end
  node.element_children.each {|n| add_button(n) }
end

display(x.root_node.element_children.first)
f.wait_until_closed
