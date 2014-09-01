(function() {
  var BrowserWindow, aggregator, app, mainWindow, path;

  path = require('path');

  app = require('app');

  aggregator = require('./aggregator');

  BrowserWindow = require('browser-window');

  require('crash-reporter').start();

  mainWindow = null;

  app.on('window-all-closed', function() {
    if (!(process.platform === 'darwin')) {
      return app.quit();
    }
  });

  app.on('ready', function() {
    var Agg, agg, clientPath, objectCount, objectStore;
    mainWindow = new BrowserWindow({
      width: 800,
      height: 600
    });
    clientPath = path.normalize("" + __dirname + "/../client");
    mainWindow.loadUrl("file://" + clientPath + "/index.html");
    mainWindow.on('closed', function() {
      return mainWindow = null;
    });
    Agg = aggregator();
    agg = new Agg;
    objectCount = [];
    objectStore = [];
    return agg.run(objectStore, objectCount);
  });

}).call(this);
