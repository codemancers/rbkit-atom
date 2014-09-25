ipc = require('ipc')
zmq = require('zmq')

controlSocket = zmq.socket('req')

controlSocket.connect('tcp://127.0.0.1:5556')
ipc.on(
  'asynchronous-message',
  (event, arg) ->
    switch arg
      when 'triggerGC'
        console.log('Triggerring GC')
        controlSocket.send('trigger_gc')
        console.log('Triggerring GC')
)
