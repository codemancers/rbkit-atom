# Subscribe
# Append to Sqlite

zmq = require('zmq')
msgpack = require('msgpack')
aggregator = ->
  subSocket = zmq.socket('sub')
  sqlite    = require('sqlite3')
  db = new sqlite.Database(':memory:')
  db.serialize ->
    db.run('create table obj_created (timestamp TEXT, classname TEXT, objectId TEXT)')
    db.run('create table obj_destroyed (timestamp TEXT, objectId TEXT)')

  subSocket.connect('tcp://127.0.0.1:5555')
  subSocket.subscribe('')

  subSocket.on(
    'message',
    (data) ->
      unpackedData = msgpack.unpack(data)
      db.serialize ->
        switch unpackedData.event_type
          when 'obj_created'
            db.run(
              "insert into obj_created values (
              #{unpackedData.timestamp.toString()},
              #{unpackedData.payload.class},
              #{unpackedData.payload.object_id.toString()}
              )"
            )
          when 'obj_destroyed'
            db.run(
              "insert into obj_destroyed values (
              #{unpackedData.timestamp.toString()},
              #{unpackedData.payload.object_id.toString()}
              )"
            )
  )

module.exports = aggregator



# Initialize IPC and aggregate for 1 second duration




# Clean up tables every 10 seconds
