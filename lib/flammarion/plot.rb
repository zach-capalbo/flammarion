module Flammarion

  # A representation of a plot in an engraving
  class Plot
    attr_reader :engraving

    # Creates a plot with it's own engraving.
    # @overload initialize()
    #  @example
    #   p = Flammarion::Plot.new
    #   p.plot([1,2,3,4])
    #   p.plot([5,6,7])
    # @overload initialize(i,t,e)
    #  @api private
    def initialize(*args)
      if args.size == 0 then
        @engraving = Engraving.new
        @id = @engraving.make_id
        @target = "default"
      elsif args.size == 3 then
        id, target, engraving = args
        @id = id
        @target = target
        @engraving = engraving
      else
        raise ArgumentError.new("ArgumentError: wrong number of arguments (#{args.size} for 0 or 3)")
      end
    end

    # Plots data to this current plot. If it has previously been plotted, this
    # plot will be overwritten. If you want to add a new plot to an engraving,
    # then use +Flammarion::Writeable.plot+.
    # @see https://plot.ly/javascript/
    # @return [Plot] A Plot object for manipulation after creation.
    # @overload plot(array, options = {})
    #   @param [Array<Number>] values A list of numbers to plot
    #   @example
    #     f.plot([1,3,4,2])
    #   @example
    #     f.plot(100.times.map{rand}, mode: 'markers')
    # @overload plot(dataset, options = {})
    #   @param [Hash] A hash representing a Plotly trace
    #   @example
    #     f.plot(x: (1..314).to_a.map{|x| Math.sin(x.to_f / 20.0)}, y:(1..314).to_a.map{|x| Math.sin(x.to_f / 10)}, replace:true)
    #   @example
    #     f.plot(x: [Time.now, Time.now + 24*60*60].map(&:to_s), y: [55, 38], type:'bar', replace:true)
    # @overload plot(datasets, options = {})
    #   @param [Array<Hash>] An array of Plotly traces
    #   @example
    #     f.plot(5.times.map{|t| {x: 100.times.to_a, y: 100.times.map{rand * t}, name: "Trace #{t}"}}, xaxis: {title: "A non-random number"}, yaxis: {title: "A random number"})
    def plot(data, options = {})
      if data.respond_to?(:keys)
        options = options.merge(data)
        if data.include?(:xy) then
          data = data.clone
          data[:x] = data[:xy].map(&:first)
          data[:y] = data[:xy].map(&:last)
          data.delete(:xy)
        end
        data = [data]
      elsif not data.first.respond_to?(:keys)
        data = [{y:data, x:(1..data.size).to_a}.merge(options)]
      end
      @engraving.send_json({action:'plot', id:@id, target:@target, data:data}.merge(options))
    end

    def to_png
    end

    # Changes the layout of an already existing plot.
    # @see https://plot.ly/javascript/#layout-options
    def layout(options)
      @engraving.send_json({action:'plot', id:@id, target: @target, layout: options})
    end
  end
end
