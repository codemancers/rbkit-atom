// Generated by CoffeeScript 1.7.1
var Aggregator, aggregator, msgpack, zmq, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

zmq = require('zmq');

msgpack = require('msgpack');

_ = require('./underscore.js');

Aggregator = (function() {
  function Aggregator() {
    this.run = __bind(this.run, this);
  }

  Aggregator.prototype.run = function(objectStoreList) {
    var subSocket;
    subSocket = zmq.socket('sub');
    subSocket.connect('tcp://127.0.0.1:5555');
    subSocket.subscribe('');
    this.previousTimestamp = 0;
    return subSocket.on('message', function(data) {
      var existingObjectStore, existingStats, existingStatsObject, unpackedData;
      unpackedData = msgpack.unpack(data);
      existingObjectStore = _.find(objectStoreList, function(objectStore) {
        return objectStore.timestamp === unpackedData.timestamp;
      });
      if (existingObjectStore) {
        switch (unpackedData.event_type) {
          case 'obj_created':
            existingStats = _.find(existingObjectStore.stats, function(statsObj) {
              return statsObj.className === unpackedData.payload["class"];
            });
            if (existingStats) {
              existingStats.count += 1;
              existingStats.object_ids.push(unpackedData.payload.object_id);
            } else {
              existingObjectStore.stats.push({
                className: unpackedData.payload["class"],
                count: 1,
                object_ids: [unpackedData.payload.object_id]
              });
            }
            break;
          case 'obj_destroyed':
            existingStatsObject = _.find(existingObjectStore.stats, function(statsObj) {
              return statsObj.object_ids.indexOf(unpackedData.payload.object_id) > -1;
            });
            if (existingStatsObject) {
              existingStatsObject.stats.count -= 1;
              existingStatsObject.stats.object_ids = _.difference(existingStatsObject.stats.object_ids, [unpackedData.payload.object_id]);
            } else {

            }
        }
      } else {
        objectStoreList.push({
          timestamp: unpackedData.timestamp,
          stats: [
            {
              className: unpackedData.payload["class"],
              count: 1,
              object_ids: [unpackedData.payload.object_id]
            }
          ]
        });
      }
      return console.log(objectStoreList);
    });
  };

  return Aggregator;

})();

aggregator = function() {
  return Aggregator;
};

module.exports = aggregator;
