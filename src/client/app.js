(function() {
  var grapher, ipc, updater;

  ipc = require('ipc');

  grapher = new Graph('#chart');

  updater = function() {
    setTimeout(updater, 1000);
    return ipc.send('asynchronous-message', 'sendData');
  };

  ipc.on('asynchronous-reply', function(data) {
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
      return grapher.renderGraphAndLegend();
    }
  });

  updater();

}).call(this);
