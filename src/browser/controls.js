(function() {
  var controlSocket, ipc, zmq;

  ipc = require('ipc');

  zmq = require('zmq');

  controlSocket = zmq.socket('req');

  controlSocket.connect('tcp://127.0.0.1:5556');

  ipc.on('asynchronous-message', function(event, arg) {
    switch (arg) {
      case 'triggerGC':
        controlSocket.send('trigger_gc');
        return console.log('GC trigger command sent');
      case 'startProfiling':
        controlSocket.send('start_memory_profile');
        return console.log('Memory profile start command sent');
      case 'stopProfiling':
        controlSocket.send('stop_memory_profile');
        return console.log('Memory profile stop command sent');
    }
  });

}).call(this);
