# Subscribe
# Append to Sqlite

zmq = require('zmq')
msgpack = require('msgpack')
_ = require('../../vendor/underscore.js')
ipc = require('ipc')
# objectStoreList would have something like this:
# { timestamp: xxxxx, stats: [ { className: xxxxx, count: xxx, object_ids:[] }, { className: xxx, count: xxx }] }
# { timestamp: yyyyy, stats: [ { className: xxxxx, count: xxx }, { className: xxx, count: xxx }] }
# TODO The count can be removed since object_ids is an array. stats.object_ids.length can be called
# This should be changed to two classes:
#
# objectStore: [ {className: 'String', object_ids: []}, {}, {}]
# objectCount: [ { className: 'String', count: 0 } ]
#
# objectStore will have a collection of a map between className and objectIds
# objectCount will have a collection of a map between className and count
#
# These two should act like subscribers to the socket data that is being streamed
#
class Aggregator
  run: (objectStore, objectCount, gcStats, mainWindow) =>

    subSocket = zmq.socket('sub')

    subSocket.connect('tcp://127.0.0.1:5555')
    subSocket.subscribe('')
    ipc.on(
      'asynchronous-message',
      (event, arg) ->
        switch arg
          when 'sendObjCount'
            event.sender.send('objCount', objectCount)
          when 'sendGcStats'
            event.sender.send('gcStats', gcStats)
          when 'sendHeapData'
            requiredData ={
              'Heap Size': gcStats.total_heap_size,
              'Mem Size': gcStats.total_memsize,
            }
            event.sender.send('heapData', requiredData)
    )

    subSocket.on(
      'message',
      (data) ->
        unpackedData = msgpack.unpack(data)
        switch unpackedData.event_type
          when 'event_collection'
            payload = unpackedData.payload
            for payloadData in payload
              switch payloadData.event_type
                when 'gc_start'
                  mainWindow.webContents.send('gc_start', payloadData.timestamp)
                when 'gc_end_s'
                  mainWindow.webContents.send('gc_end', payloadData.timestamp)
                when 'gc_stats'
                  gcStats = _.clone(payloadData.payload)
                when 'obj_created'
                  existingObjectStore = _.find(
                    objectStore,
                    (objectStoreData) ->
                      objectStoreData.className is payloadData.payload.class
                  )
                  existingCount = _.find(
                    objectCount,
                    (objectCountData) ->
                      objectCountData.className is payloadData.payload.class
                  )
                  if existingObjectStore
                    existingObjectStore.object_ids.push(payloadData.payload.object_id)
                    existingCount.count += 1
                  else
                    objectStore.push(
                      className: payloadData.payload.class
                      object_ids: [ payloadData.payload.object_id ]
                    )
                    objectCount.push(
                      className: payloadData.payload.class
                      count: 1
                    )
                when 'obj_deleted'
                  existingObjectStore = _.find(
                    objectStore,
                    (objectStoreData) ->
                      objectStoreData.object_ids.indexOf(payloadData.payload.object_id) > -1
                  )
                  existingCount = _.find(
                    objectCount,
                    (objectCountData) ->
                      objectCountData.className is existingObjectStore.className
                  )
                  if existingObjectStore
                    existingObjectStore = _.difference(
                      existingObjectStore.object_ids,
                      [ payloadData.payload.object_id ]
                    )
                    existingCount -= 1
    )

aggregator =  -> Aggregator
module.exports = aggregator
