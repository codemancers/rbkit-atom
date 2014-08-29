app = require 'app'

BrowserWindow = require 'browser-window'
require('crash-reporter').start()

mainWindow = null

app.on(
  'window-all-closed',
   ->
     app.quit() unless(process.platform is 'darwin')
)

app.on(
  'ready',
   ->
     mainWindow = new BrowserWindow(width: 800, height: 600)
     mainWindow.loadUrl("file://#{__dirname}/index.html")
     mainWindow.on(
       'closed',
        ->
          mainWindow = null
     )
)
