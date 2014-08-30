# Subscribe
# Append to Sqlite

zmq = require('zmq')
msgpack = require('msgpack')
_ = require('./underscore.js')

# objectStoreList would have something like this:
# { timestamp: xxxxx, stats: [ { className: xxxxx, count: xxx, object_ids:[] }, { className: xxx, count: xxx }] }
# { timestamp: xxxxx, stats: [ { className: xxxxx, count: xxx }, { className: xxx, count: xxx }] }
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
        else
          objectStoreList.push(
            timestamp: unpackedData.timestamp,
            stats: [
              className: unpackedData.payload.class,
              count: 1,
              object_ids: [unpackedData.payload.object_id ]
            ]
          )
        console.log JSON.stringify(objectStoreList)
    )
  getStats: =>
    @objectStore

aggregator =  -> Aggregator
module.exports = aggregator

# Initialize IPC and aggregate for 1 second duration




# Clean up tables every 10 seconds
