(function() {
  var gcGrapher, gcStatsUpdater, grapher, ipc, objCountUpdater;

  ipc = require('ipc');

  grapher = new Graph('#chart');

  gcGrapher = new GcChart('#gc-chart');

  objCountUpdater = function() {
    setTimeout(objCountUpdater, 1000);
    return ipc.send('asynchronous-message', 'sendObjCount');
  };

  gcStatsUpdater = function() {
    setTimeout(gcStatsUpdater, 3000);
    return ipc.send('asynchronous-message', 'sendGcStats');
  };

  ipc.on('gcStats', function(data) {
    if (_.isEmpty(data)) {
      return;
    }
    return grapher.updateGcStats(data);
  });

  ipc.on('objCount', function(data) {
    var formatForOldData, oldStyleData;
    formatForOldData = function(newDataFormat) {
      var values;
      values = _.map(newDataFormat, function(objData) {
        return [objData.className, objData.count];
      });
      return _.object(values);
    };
    if (data.length) {
      oldStyleData = formatForOldData(data);
      grapher.addData(oldStyleData);
      grapher.renderGraphAndLegend();
      return gcGrapher.renderGraph();
    }
  });

  ipc.on('gc_start', function(message) {
    return gcGrapher.gcStart();
  });

  ipc.on('gc_end', function(message) {
    return gcGrapher.gcEnd();
  });

  objCountUpdater();

  gcStatsUpdater();

}).call(this);
