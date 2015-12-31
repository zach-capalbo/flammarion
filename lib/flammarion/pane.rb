require_relative 'writeable.rb'

module Flammarion
  # A reference to some writeable area within the {Engraving}
  # @see Writeable
  # @see Engraving
  class Pane
    include Writeable

    # @api private
    def initialize(engraving, name, options = {})
      @engraving = engraving
      @pane_name = name
      @options = {}
    end
  end
end
