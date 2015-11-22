app = require 'app'
BrowserWindow = require('browser-window')
require('crash-reporter').start()

app.on 'ready', ->
  main_window = new BrowserWindow({width:800, height: 600, "node-integration": false})
  main_window.loadUrl("http://localhost:4567")
  main_window.openDevTools();
