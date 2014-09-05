(function() {
  var Aggregator, aggregator, ipc, msgpack, zmq, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  zmq = require('zmq');

  msgpack = require('msgpack');

  _ = require('../../vendor/underscore.js');

  ipc = require('ipc');

  Aggregator = (function() {
    function Aggregator() {
      this.run = __bind(this.run, this);
    }

    Aggregator.prototype.run = function(objectStore, objectCount, gcStats, mainWindow) {
      var subSocket;
      subSocket = zmq.socket('sub');
      subSocket.connect('tcp://127.0.0.1:5555');
      subSocket.subscribe('');
      ipc.on('asynchronous-message', function(event, arg) {
        switch (arg) {
          case 'sendObjCount':
            return event.sender.send('objCount', objectCount);
          case 'sendGcStats':
            return event.sender.send('gcStats', gcStats);
        }
      });
      return subSocket.on('message', function(data) {
        var existingCount, existingObjectStore, payload, payloadData, unpackedData, _i, _len, _results;
        unpackedData = msgpack.unpack(data);
        switch (unpackedData.event_type) {
          case 'event_collection':
            payload = unpackedData.payload;
            _results = [];
            for (_i = 0, _len = payload.length; _i < _len; _i++) {
              payloadData = payload[_i];
              switch (payloadData.event_type) {
                case 'gc_stats':
                  _results.push(gcStats = _.clone(payloadData.payload));
                  break;
                case 'gc_start':
                  _results.push(mainWindow.webContents.send('gc_start', ''));
                  break;
                case 'gc_end_s':
                  _results.push(mainWindow.webContents.send('gc_end', ''));
                  break;
                case 'obj_created':
                  existingObjectStore = _.find(objectStore, function(objectStoreData) {
                    return objectStoreData.className === payloadData.payload["class"];
                  });
                  existingCount = _.find(objectCount, function(objectCountData) {
                    return objectCountData.className === payloadData.payload["class"];
                  });
                  if (existingObjectStore) {
                    existingObjectStore.object_ids.push(payloadData.payload.object_id);
                    _results.push(existingCount.count += 1);
                  } else {
                    objectStore.push({
                      className: payloadData.payload["class"],
                      object_ids: [payloadData.payload.object_id]
                    });
                    _results.push(objectCount.push({
                      className: payloadData.payload["class"],
                      count: 1
                    }));
                  }
                  break;
                case 'obj_deleted':
                  existingObjectStore = _.find(objectStore, function(objectStoreData) {
                    return objectStoreData.object_ids.indexOf(payloadData.payload.object_id) > -1;
                  });
                  existingCount = _.find(objectCount, function(objectCountData) {
                    return objectCountData.className === existingObjectStore.className;
                  });
                  if (existingObjectStore) {
                    existingObjectStore = _.difference(existingObjectStore.object_ids, [payloadData.payload.object_id]);
                    _results.push(existingCount -= 1);
                  } else {
                    _results.push(void 0);
                  }
                  break;
                default:
                  _results.push(void 0);
              }
            }
            return _results;
        }
      });
    };

    return Aggregator;

  })();

  aggregator = function() {
    return Aggregator;
  };

  module.exports = aggregator;

}).call(this);
