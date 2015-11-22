class StatusDisplay
  status_history: []
  waiting_statuses: []
  max_statuses: 10
  constructor: (@ws, @target) ->
    console.log("Setting up status bar at #{@target}")
    @target.click =>
      @show_history()

  show_status: (data) ->
    @target.html(@ws.escape(data.text, data))
    @status_history << data

  show_history: ->
    alert(@status_history)

window.StatusDisplay = StatusDisplay
