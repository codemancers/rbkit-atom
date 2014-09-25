ipc = require('ipc')
zmq = require('zmq')

controlSocket = zmq.socket('req')

controlSocket.connect('tcp://127.0.0.1:5556')
ipc.on(
  'asynchronous-message',
  (event, arg) ->
    switch arg
      when 'triggerGC'
        controlSocket.send('trigger_gc')
        console.log('GC trigger command sent')
      when 'startProfiling'
        controlSocket.send('start_memory_profile')
        console.log('Memory profile start command sent')
      when 'stopProfiling'
        controlSocket.send('stop_memory_profile')
        console.log('Memory profile stop command sent')
)
