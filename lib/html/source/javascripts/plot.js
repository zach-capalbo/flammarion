/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
$(document).ready(() => window.default_plot_options = {
  plot_bgcolor: $('#plot-style').css("background-color"),
  paper_bgcolor: $('#plot-style').css("background-color"),
  font: {
    color: $('#plot-style').css("color"),
    family: $('pre').css("font-family")
  },
  titlefont: {
    color: $('#plot-style').css("color"),
    family: $('body').css("font-family")
  },
  yaxis: {
    gridcolor: $('#plot-style > .tickmarks').css("color")
  },
  xaxis: {
    gridcolor: $('#plot-style > .tickmarks').css("color")
  },
  margin: {
    t: 10,
    b: 40
  }
});


$.event.special.removed = {
  remove(o) {
    if (o.handler) { return o.handler(); }
  }
};

$.extend(WSClient.prototype.actions, {
  plot(data) {
    const target = this.__parent.check_target(data);
    if (!this.__plots) { this.__plots = {}; }
    let plotDiv = target.find(`#plot-${data.id}`);
    if (plotDiv.size() === 0) {
      plotDiv = $(`<div class='plot' id='plot-${data.id}'></div>`);
      this.__parent.add(plotDiv, target, data);
      $(window).resize(() => Plotly.relayout(plotDiv[0], {width: plotDiv.width(), height:plotDiv.height()}));
      return Plotly.newPlot(plotDiv[0], data.data, $.extend({width: plotDiv.width()}, window.default_plot_options, data));
    } else {
      plotDiv[0].data = data.data;
      Plotly.redraw(plotDiv[0]);
      if (data.layout) { return Plotly.relayout(plotDiv[0], data); }
    }
  },
  savePlot(data) {
    const target = this.__parent.check_target(data);
    if (!this.__plots) { this.__plots = {}; }
    const plotDiv = target.find(`#plot-${data.id}`)[0];
    return Plotly.toImage(plotDiv, data.format).then(imgData => {
      return this.__parent.send({
        id:data.callback_id,
        action:'callback',
        source:'plot',
        data: imgData,
        original_msg:data
        });
    });
  }
}
);
