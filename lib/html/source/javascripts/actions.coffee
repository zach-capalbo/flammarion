#= require websocket.coffee
$.extend WSClient.prototype.actions,
  append: (data) ->
    @__parent.check_target(data)
    element = $("#console-#{data.target}")
    marginSize = 16

    atBottomStack = []
    while element.hasClass("pane")
      atBottom = element.scrollTop() >= element[0].scrollHeight - element.height() - marginSize - 2 or element[0].scrollHeight - marginSize < element.height()
      atBottomStack.push atBottom
      element = element.parent()

    element = $("#console-#{data.target}")
    element.append(@__parent.escape(data.text, data))

    while element.hasClass("pane")
      atBottom = atBottomStack.shift()
      element.scrollTop(element[0].scrollHeight - element.height() - marginSize) if atBottom
      element = element.parent()

  replace: (data) ->
    @__parent.check_target(data)
    $("#console-#{data.target}").html(@__parent.escape(data.text, data))

  clear: (data) ->
    @__parent.check_target(data)
    $("#console-#{data.target}").html("") # empty() is really slow for some reason

  addpane: (data) ->
    if data.target
      target = @__parent.check_target(data)
    else
      target = $('#panes')

    if target.find("#console-#{data.name}").size() is 0
      element = $("<pre class='pane full-pane' id='console-#{data.name}'><pre>")
      element.attr('pane-weight', data.weight || 1)
      target.append(element)
    @__parent.resize_panes(data)

  closepane: (data) ->
    target = $("#console-#{data.target}")
    unless target.size() is 0
      target.remove()
      @__parent.resize_panes(data)

  hidepane: (data) ->
    target = @__parent.check_target(data)
    target.addClass("hidden")
    target.removeClass("pane")
    @__parent.resize_panes({target_element:target.parent()})

  showpane: (data) ->
    target = @__parent.check_target(data)
    target.addClass("pane")
    target.removeClass("hidden")
    @__parent.resize_panes(data)

  reorient: (data) ->
    if data.target
      target = @__parent.check_target(data)
    else
      target = $('#panes')

    if data.orientation is "horizontal"
      target.addClass("horizontal")
    else
      target.removeClass("horizontal")
    @__parent.resize_panes(data)

  highlight: (data) ->
    target = @__parent.check_target(data)
    code = $("<code>#{ansi_up.escape_for_html(data.text)}</code>")
    code.addClass data.language if data.language
    @__parent.add(code, target, data)
    hljs.highlightBlock(code[0])

  markdown: (data) ->
    target = @__parent.check_target(data)
    newblock = $("<div class='markdown'></div>")
    newblock.html(@__parent.escape(data.text, $.extend({escape_html:false, escape_icons:true}, data)))
    @__parent.add(newblock, target, data)
    hljs.highlightBlock(code) for code in newblock.find('code')

  break: (data) ->
    target = @__parent.check_target(data)
    code = $("<hr>")
    @__parent.add(code, target, data)

  subpane: (data) ->
    target = @__parent.check_target(data)
    element = target.find("#console-#{data.name}")
    if element.size() is 0
      other_classes = "subpane-fill" if data.fill
      target.append("<pre id='console-#{data.name}' class='subpane pane #{other_classes}'></pre>")

  alert: (data) ->
    alert(data.text)

  title: (data) ->
    document.title = data.title

  status: (data) ->
    @__parent.status.show_status(data)

  layout: (data) ->
    $("body").html(data.data)

  script: (data) ->
    r = eval(data.data)
    @__parent.send({
      id:data.id
      action:'callback'
      source:'script'
      original_msg:data
      result: r
      })

  style: (data) ->
    target = @__parent.check_target(data)
    target.css(data.attribute, data.value)

  table: (data) ->
    target = @__parent.check_target(data)
    html = "<table>"
    if data.headers
      html += "<tr>"
      html += "<th>#{@__parent.escape(header, data)}</th>" for header in data.headers
      html += "<tr>"
    for row in data.rows
      html += "<tr>"
      html += "<td>#{@__parent.escape(cell, data)}</td>" for cell in row
      html += "</tr>"
    html += "</table>"
    html = $(html)
    unless data.interactive is false
      html.delegate 'td', 'mouseover mouseout', ->
        pos = $(this).index()
        html.find("td:nth-child(#{(pos+1)})").toggleClass("hover")
    @__parent.add(html, target, data)

  focus: (data) ->
    window.show()

  close: (data) ->
    window.close()

  search: (data) ->
    if window.find(data.text, 0, 0, 1)
      anchor = window.getSelection().anchorNode
      anchor = anchor.parentNode unless anchor.nodeType == 1
      anchor.scrollIntoView()
