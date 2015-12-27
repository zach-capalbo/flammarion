window.$remote = require('remote')

window.onkeyup = (e) ->
  if e.ctrlKey and e.keyCode is 70
    window.show_search_bar()
