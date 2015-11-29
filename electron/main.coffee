app = require 'app'
BrowserWindow = require('browser-window')
require('crash-reporter').start()
path = require('path')

app.on 'ready', ->
  preload = path.resolve(path.join(__dirname, 'preload.js'))
  main_window = new BrowserWindow({width:800, height: 600, "node-integration": false, "web-security":false, preload:preload})
  main_window.loadUrl(process.argv[2])
