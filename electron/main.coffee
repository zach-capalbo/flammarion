app = require('electron').app
{BrowserWindow} = require('electron')
path = require('path')
shell = require('electron').shell

app.on 'ready', ->
  preload = path.resolve(path.join(__dirname, 'preload.js'))
  main_window = new BrowserWindow
    width: parseInt(process.argv[3]) || 800
    height: parseInt(process.argv[4]) || 600
    webPreferences:
      nodeIntegration: false
      webSecurity: false
    icon:"icon.png"
    preload:preload
  main_window.loadURL(process.argv[2])
  main_window.setMenu(null)
  main_window.webContents.on 'new-window', (event, url) ->
    event.preventDefault()
    shell.openExternal(url)