window.$remote = require('remote')

webFrame = require('web-frame')

try
  spellcheck = require('spellchecker')

  webFrame.setSpellCheckProvider("en-US", true, {
    spellCheck: (text) ->
      return !spellcheck.isMisspelled(text)
    })
catch (error)
  console.log("Could not load spellchecker: #{error}")

window.onkeyup = (e) ->
  if e.ctrlKey and e.keyCode is 70
    window.show_search_bar()
