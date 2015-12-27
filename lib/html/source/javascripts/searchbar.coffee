window.show_search_bar = ->
  $('#searchbar').show()
  $('#searchbar > input').focus()

$(document).ready ->
  $('#searchbar > input').change ->
    text = $('#searchbar > input')[0].value
    $('#searchbar').hide()
    $('#searchbar > input')[0].value = ""
    console.log "Searching #{text}"
    if window.find(text, 0, 0, 1)
      console.log "Found #{text}"
      anchor = window.getSelection().anchorNode
      anchor = anchor.parentNode unless anchor.nodeType == 1
      anchor.focus()
      anchor.scrollIntoView()
    else
      alert("Cannot find #{text}")
    # $('#searchbar > input')[0].value = text
