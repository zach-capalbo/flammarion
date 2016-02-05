app = require 'app'
BrowserWindow = require('browser-window')
path = require('path')

app.on 'ready', ->
  preload = path.resolve(path.join(__dirname, 'preload.js'))
  main_window = new BrowserWindow
    width:800
    height: 600
    "node-integration": false
    "web-security":false
    icon:"icon.png"
    preload:preload
  main_window.loadURL(process.argv[2])
