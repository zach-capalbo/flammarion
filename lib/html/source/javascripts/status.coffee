class StatusDisplay
  status_history: []
  waiting_statuses: []
  max_statuses: 10
  constructor: (@ws, @target) ->
    @target.click =>
      @show_history()

  show_status: (data) ->
    @target.html(@ws.escape(data.text, data))
    @status_history.push data

  show_history: ->
    console.log(@status_history)
    message = "<ul>#{("<li>#{@ws.escape(item.text, item)}</li>" for item in @status_history).join("\n")}</ul>"
    $('#dialog > #content > #message').html(message)
    $('#dialog').show()
    $('#dialog > #content > #ok').click ->
      $('#dialog').hide()

window.StatusDisplay = StatusDisplay
