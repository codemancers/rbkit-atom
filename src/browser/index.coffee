path = require('path')
app = require 'app'
aggregator = require './aggregator'

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
    mainWindow = new BrowserWindow(width: 1000, height: 800)
    clientPath = path.normalize("#{__dirname}/../client")
    mainWindow.loadUrl("file://#{clientPath}/rbkit-charts/src/index.html")
    mainWindow.on(
      'closed',
       ->
         mainWindow = null
    )
    Agg = aggregator()
    agg = new Agg
    objectCount = []
    objectStore = []
    gcStats = {}
    agg.run(objectStore, objectCount, gcStats, mainWindow)
)
