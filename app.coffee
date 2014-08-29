zmq = require('zmq')
msgpack = require('msgpack')
subSocket = zmq.socket('sub')

subSocket.connect('tcp://127.0.0.1:5555')
subSocket.subscribe('')

subSocket.on(
  'message',
  (data) ->
    unpackedData = msgpack.unpack(data)
    switch unpackedData.event_type
      when 'obj_created'
        grapher.addData(unpackedData.payload)
      when "gc_stats"
        grapher.updateGcStats(unpackedData.payload)
    grapher.renderGraphAndLegend()
)

grapher = new Graph('#chart')
