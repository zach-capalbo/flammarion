require_relative 'writeable.rb'

module Flammarion
  class Pane
    attr_reader :pane_name
    include Writeable
    def initialize(front_end, name, options = {})
      @front_end = front_end
      @pane_name = name
      @options = {}
    end
  end
end
