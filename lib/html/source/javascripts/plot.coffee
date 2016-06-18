$(document).ready ->
  window.default_plot_options =
    plot_bgcolor: $('#plot-style').css("background-color")
    paper_bgcolor: $('#plot-style').css("background-color")
    font:
      color: $('#plot-style').css("color")
      family: $('pre').css("font-family")
    titlefont:
      color: $('#plot-style').css("color")
      family: $('body').css("font-family")
    yaxis:
      gridcolor: $('#plot-style > .tickmarks').css("color")
    xaxis:
      gridcolor: $('#plot-style > .tickmarks').css("color")
    margin:
      t: 10
      b: 40


$.event.special.removed =
  remove: (o) ->
    o.handler() if o.handler

$.extend WSClient.prototype.actions,
  plot: (data) ->
    target = @__parent.check_target(data)
    @__plots ||= {}
    plotDiv = target.find("#plot-#{data.id}")
    if plotDiv.size() is 0
      plotDiv = $("<div class='plot' id='plot-#{data.id}'></div>")
      @__parent.add(plotDiv, target, data)
      $(window).resize ->
        Plotly.relayout plotDiv[0], {width: plotDiv.width(), height:plotDiv.height()}
      Plotly.newPlot(plotDiv[0], data.data, $.extend(width: plotDiv.width(), window.default_plot_options, data))
    else
      plotDiv[0].data = data.data
      Plotly.redraw(plotDiv[0])
      Plotly.relayout(plotDiv[0], data) if data.layout
