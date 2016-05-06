#= require vendor/jquery.js
#= require status.coffee
#= require fontawesome.js
#= require vendor/emojione.min.js

emojione.imagePathPNG = 'images/emoji/'

class WSClient
  constructor: ->
    host = $qs.get("host") || "localhost"
    console.log "Path: #{$qs.get("path")}, Port: #{$qs.get("port")}, Host: #{host}"
    @ws = new WebSocket "ws://#{host}:#{$qs.get("port")}/#{$qs.get("path")}"
    @actions["__parent"] = this
    document.title = decodeURIComponent($qs.get("title")) || "Flammarion"
    @ws.onopen = (msg) ->
      $('body').addClass("connected")

    @ws.onclose = (msg) ->
      $('body').removeClass("connected")

    @ws.onmessage = (msg) =>
      console.log(msg)
      data = $.parseJSON(msg.data)
      if @actions[data.action]
        @actions[data.action](data)
      else
        console.error("No such action: #{data.action}")

    @status = new StatusDisplay(this, $('#status > .right'))

  send: (data) ->
    @ws.send JSON.stringify(data)

  check_target: (data) ->
    return data.target_element if data.target_element
    data.target = "default" unless data.target
    @actions.addpane {name:data.target} if $("#console-#{data.target}").size() is 0
    @resize_panes
    return $("#console-#{data.target}")

  resize_panes: (data) ->
    if data.target
      target = @check_target(data)
    else
      target = $('#panes')

    allPanes =  target.find('> .pane')
    if target.hasClass('horizontal')
      orientation = 'horizontal'
    else
      orientation = 'vertical'

    total_weight = ((parseFloat($(i).attr('pane-weight') || 1.0)) for i in allPanes).reduce (t,s) -> t + s
    # total_weight = (allPanes.map((i) -> parseFloat(i[].attr('pane-weight')))).reduce (t, s) -> t + s

    p_height = (pane) -> (parseFloat($(pane).attr('pane-weight') || 1.0) / total_weight * 100).toFixed(0) + "%"
    console.log target, allPanes.size(), 100.0 / allPanes.size(), total_weight, orientation
    for pane in allPanes
      if orientation is 'horizontal'
        $(pane).css "width", p_height(pane)
        $(pane).css "height", '100%'
      else
        $(pane).css "height", p_height(pane)
        $(pane).css "width", '100%'

  relink: (text) ->
    text.replace(/\<a href=['"](https?:\/\/[^\s]+)["']>/gm, (str, l) ->
      "<a href=\"#{l}\" target='_blank'>"
    )

  escape: (text, input_options) ->
    options =
      raw: false
      colorize: true
      escape_html: true
      escape_icons: false
    $.extend(options, input_options)
    return text if options.raw
    text = "#{text}"
    text = ansi_up.escape_for_html(text) if options.escape_html
    text = ansi_up.ansi_to_html(text, {use_classes:true}) if options.colorize
    if options.escape_icons
      text = text.replace /:[\w-]+:/g, (match) ->
        if font_awesome_list.includes(match[1..-2]) then "<i class='fa fa-#{match[1..-2]}'></i>" else match

    text = emojione.toImage(text) if options.escape_icons
    text = $("<div>#{text}</div>")
    text.find("a[href^='http']").attr('target','_blank')
    return text.html()

  add: (object, target, data) ->
    object.find("a[href^='http']").attr('target','_blank')
    if data.style
      object.css(key, val) for own key, val of data.style
    if data.replace
      target.html(object)
    else
      target.append(object)

  actions:
    __parent: null

$(document).ready ->
  window.$ws = new WSClient

window.WSClient = WSClient
