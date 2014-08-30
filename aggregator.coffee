# Subscribe
# Append to Sqlite

zmq = require('zmq')
msgpack = require('msgpack')
_ = require('./underscore.js')

# objectStoreList would have something like this:
# { timestamp: xxxxx, stats: [ { className: xxxxx, count: xxx, object_ids:[] }, { className: xxx, count: xxx }] }
# { timestamp: yyyyy, stats: [ { className: xxxxx, count: xxx }, { className: xxx, count: xxx }] }
# TODO The count can be removed since object_ids is an array. stats.object_ids.length can be called
class Aggregator
  run: (objectStoreList) =>
    subSocket = zmq.socket('sub')

    subSocket.connect('tcp://127.0.0.1:5555')
    subSocket.subscribe('')
    @previousTimestamp = 0

    subSocket.on(
      'message',
      (data) ->
        unpackedData = msgpack.unpack(data)
        existingObjectStore = _.find(
          objectStoreList,
          (objectStore) ->
            objectStore.timestamp is unpackedData.timestamp
        )

        if existingObjectStore
          switch unpackedData.event_type
            when 'obj_created'
              existingStats = _.find(
                existingObjectStore.stats,
                (statsObj) ->
                  statsObj.className is unpackedData.payload.class
              )
              if existingStats
                existingStats.count += 1
                existingStats.object_ids.push(unpackedData.payload.object_id)
              else
                existingObjectStore.stats.push(
                  className: unpackedData.payload.class,
                  count: 1,
                  object_ids: [ unpackedData.payload.object_id ]
                )
            when 'obj_destroyed'
              existingStatsObject = _.find(
                existingObjectStore.stats,
                (statsObj) ->
                  statsObj.object_ids.indexOf(unpackedData.payload.object_id) > -1
              )
              if existingStatsObject
                existingStatsObject.stats.count -= 1
                existingStatsObject.stats.object_ids = _.difference(
                  existingStatsObject.stats.object_ids,
                  [ unpackedData.payload.object_id ]
                )
              else
                # Find out why sometimes this else block gets triggered
        else
          objectStoreList.push(
            timestamp: unpackedData.timestamp,
            stats: [
              className: unpackedData.payload.class,
              count: 1,
              object_ids: [unpackedData.payload.object_id ]
            ]
          )
    )

aggregator =  -> Aggregator
module.exports = aggregator

# Initialize IPC and aggregate for 1 second duration




# Clean up tables every 10 seconds
