window.$remote = require('remote')

window.$search_for = (str) ->
  if window.find(str, 0, 0, 1)
    anchor = window.getSelection().anchorNode
    anchor = anchor.parentNode unless anchor.nodeType == 1
    anchor.scrollIntoView()
