require_relative 'writeable.rb'

module Flammarion
  class Pane
    attr_reader :pane_name
    include Writeable
    def initialize(engraving, name, options = {})
      @engraving = engraving
      @pane_name = name
      @options = {}
    end
  end
end
