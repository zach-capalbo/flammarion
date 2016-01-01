$.event.special.removed =
  remove: (o) ->
    o.handler() if o.handler

$.extend WSClient.prototype.actions,
  plot: (data) ->
    target = @__parent.check_target(data)
    @__plots ||= {}
    if @__plots[data.id]
      @__plots[data.id].update(data)
    else
      @__plots[data.id] = new Plot(target, @__parent, data)

$(document).ready ->
    Plot.prototype.default_options =
      color: $('#plot-style').css("color")
      replace: true
      size: 1.0
      orientation: 'vertical'
      xscale: 1.0
      yscale: 1.0
      tick_height: 15
      number_of_ticks: 10
      tick_color: $("#plot-style > .tickmarks").css("color")
      tick_precision: 2
      id: "spec0"
      draw_zero: true
      fill_color: null
      draw_line: true
      draw_marker: false
      marker_color: $("#plot-style > .markers").css("color")
      ystart: 'min'
      fill: false
      fill_color: $('#plot-style').css("background-color")
      zero_color: $('#plot-style > .zero').css("color")

class Plot
  parse_property: (prop) ->
    parseInt(prop.slice(0, -1))

  move_zoom: (event) =>
    @zoom_box.width = event.pageX - @zoom_box.left
    @zoom_box.height = event.pageY - @zoom_box.top
    @zoom_element.css "width", "#{Math.abs(@zoom_box.width)}"
    @zoom_element.css "height", "#{Math.abs(@zoom_box.height)}"

    @zoom_element.css "left", event.pageX if @zoom_box.width < 0
    @zoom_element.css "top", event.pageY if @zoom_box.height < 0

  mousemove: (event) =>
    @mouse_element.removeClass "hidden"
    @canvas.focus()
    relative_x_pos = (event.pageX - @canvas.offset().left) / @plot_width
    relative_y_pos = 1.0 - ((event.pageY - @canvas.offset().top) / @plot_height)

    @mouse_element.css "left", "#{event.pageX + 15}px"
    @mouse_element.css "top", "#{event.pageY + 15}px"

    mouse_x_value = relative_x_pos * @xscaled_end_value + (1.0 - relative_x_pos) * @xscaled_start_value
    mouse_x_value = mouse_x_value * @xvalue_scale
    mouse_y_value = relative_y_pos * @yscaled_end_value + (1.0 - relative_y_pos) * @yscaled_start_value
    @mouse_element.text "#{mouse_x_value.toFixed(2)}, #{mouse_y_value.toFixed(2)}"

    @move_zoom(event) if @mouse_is_down

  mousedown: (event) =>
    unless @mouse_is_down
      @zoom_box ||= {}
      @zoom_box.left = event.pageX
      @zoom_box.top = event.pageY
      @zoom_element.css "left", event.pageX
      @zoom_element.css "top", event.pageY
      @zoom_element.css "width", 0
      @zoom_element.css "height", 0
      @zoom_element.removeClass("hidden")
      @mouse_is_down = true

  mouseup: (event) =>
    @mouse_is_down = false
    @zoom_element.addClass "hidden"

    zoom_width = @parse_property(@zoom_element.css "width")
    zoom_xstart_pixel = @parse_property(@zoom_element.css "left") - @canvas.offset().left
    zoom_xend_pixel = zoom_xstart_pixel + zoom_width

    relative_xstart_pos = zoom_xstart_pixel / @plot_width
    relative_xend_pos = zoom_xend_pixel / @plot_width

    zoom_xstart_value = relative_xstart_pos * @xscaled_end_value + (1.0 - relative_xstart_pos) * @xscaled_start_value
    zoom_xend_value = relative_xend_pos * @xscaled_end_value + (1.0 - relative_xend_pos) * @xscaled_start_value

    zoom_height = @parse_property(@zoom_element.css "height")
    zoom_yend_pixel = @parse_property(@zoom_element.css "top") - @canvas.offset().top
    zoom_ystart_pixel = zoom_yend_pixel + zoom_height

    relative_ystart_pos = 1.0 - ((zoom_ystart_pixel) / @plot_height)
    relative_yend_pos = 1.0 - ((zoom_yend_pixel) / @plot_height)

    zoom_ystart_value = relative_ystart_pos * @yscaled_end_value + (1.0 - relative_ystart_pos) * @yscaled_start_value
    zoom_yend_value = relative_yend_pos * @yscaled_end_value + (1.0 - relative_yend_pos) * @yscaled_start_value

    # console.log zoom_ystart_value, zoom_yend_value

    @zoom_to(zoom_xstart_value, zoom_xend_value, zoom_ystart_value, zoom_yend_value)

  keypress: (event) =>
    switch event.which
      when 114, 97
        @zoom_to(@xstart_value, @xend_value, @ystart_value, @yend_value)
        @draw(@data)

  setup_hover: ->
    @zoom_element = $('#plot-zoombox')
    if @zoom_element.size() is 0
      @zoom_element = $('<div id="plot-zoom-element" class="hidden"></div>')
      $('body').append @zoom_element

    @mouse_element = $('#plot-mouseover')
    if @mouse_element.size() is 0
      @mouse_element = $('<div id="plot-mouseover" class="hidden"></div>')
      $('body').append(@mouse_element)

    @canvas.mousemove @mousemove
    @canvas.mouseout (event) => @mouse_element.addClass "hidden"
    @canvas.mousedown @mousedown
    @canvas.mouseup @mouseup
    @canvas.keypress @keypress
    @canvas.on 'removed', => @canvas.off()

  create_container: ->
    @container = $("<div class='plot' id='#{@id}'><canvas tabindex='1'></canvas></div>")
    @__parent.add @container, @target, @options

  set_canvas_size: ->
    @container_width = @container.width()
    @container_height = @container.height()
    @canvas[0].width = @canvas_width = @container_width
    @canvas[0].height = @canvas_height = @container_height
    @set_scale_values()

  zoom_to: (@xscaled_start_value, @xscaled_end_value, @yscaled_start_value, @yscaled_end_value) ->
    @draw(@data)

  set_scale_values: ->
    @xvalue_scale = @options.xscale
    @xend_value = @options.xend || (@data.length - 1)
    @xstart_value = @options.xstart || 0

    @yvalue_scale = @options.yscale
    @ystart_value = @options.ystart || 0
    @ystart_value = Math.min(@data...) if @ystart_value is 'min'
    @yend_value = @options.yend || Math.max(@data...)

    @plot_height = @canvas_height - @options.tick_height
    @plot_width = @canvas_width

    @xscaled_start_value = @xstart_value
    @xscaled_end_value = @xend_value

    @yscaled_start_value = @ystart_value
    @yscaled_end_value = @yend_value

  y_value_to_pixel: (y) ->
    @plot_height - (y - @yscaled_start_value) / (@yscaled_end_value - @yscaled_start_value) * @plot_height

  x_value_to_pixel: (i) ->
    (i - @xscaled_start_value) / (@xscaled_end_value - @xscaled_start_value) * @plot_width

  draw: (data) ->
    @ctx.clearRect 0, 0, @canvas_width, @canvas_height
    @ctx.fillStyle = @options.marker_color
    @ctx.strokeStyle = @options.color

    @ctx.font = "8px Monospace";
    @ctx.textAlign = "center";

    @ctx.beginPath()
    @ctx.moveTo(@x_value_to_pixel(0), @y_value_to_pixel(data[0]))
    for i in [1..data.length - 1]
      @ctx.lineTo(@x_value_to_pixel(i), @y_value_to_pixel(data[i])) if @options.draw_line
      @ctx.fillText("ｘ", @x_value_to_pixel(i), @y_value_to_pixel(data[i])) if @options.draw_marker
    @ctx.moveTo(@x_value_to_pixel(0), @y_value_to_pixel(data[0]))
    @ctx.closePath()

    @ctx.fillStyle = @options.fill_color
    @ctx.fill() if @options.fill_color and @options.fill
    @ctx.stroke()
    @draw_ticks()
    @draw_zero() if @options.draw_zero

  draw_ticks: ->
    @ctx.font = "#{@options.tick_height - 3}px Monospace";
    @ctx.fillStyle = @options.tick_color
    @ctx.strokeStyle = @options.tick_color
    @ctx.textAlign = "center";
    @ctx.textBaseline = 'middle';
    number_of_ticks = @options.number_of_ticks + 1
    tick_height = @options.tick_height
    for i in [1..number_of_ticks - 1]
      @ctx.beginPath()
      pos = i * @plot_width / number_of_ticks
      @ctx.moveTo(pos, @plot_height + tick_height / 2)
      @ctx.lineTo(pos, @plot_height - tick_height)
      @ctx.stroke()

      tickStart = @xscaled_start_value
      tickEnd = @xscaled_end_value
      tickValue = i * 1.0 / number_of_ticks
      tickValue = tickValue * tickEnd + (1.0 - tickValue) * tickStart
      tickValue = tickValue * @xvalue_scale
      @ctx.textAlign = 'start'
      @ctx.fillText("#{tickValue.toFixed(@options.tick_precision)}", pos + 3, @canvas_height - 3)

    @ctx.beginPath()
    @ctx.moveTo(0, @plot_height)
    @ctx.lineTo(@canvas_width, @plot_height)
    @ctx.stroke()

  draw_zero: ->
    @ctx.strokeStyle = @options.zero_color
    @ctx.beginPath()
    @ctx.moveTo(0, @y_value_to_pixel(0))
    @ctx.lineTo(@canvas_width, @y_value_to_pixel(0))
    @ctx.stroke()

  update: (data) ->
    @data = data.data
    $.extend @options, data
    @draw(data.data)

  constructor: (@target, @__parent, @input_options) ->
    @options = $.extend({}, @default_options, @input_options)
    @id = @options.id
    @data = @options.data

    @container = @target.find("##{@id}")

    if @container.size() is 0
      @create_container()

    @canvas = @container.find("canvas")
    @ctx = @canvas[0].getContext("2d")
    @set_canvas_size()
    @setup_hover()

    @draw(@data)
