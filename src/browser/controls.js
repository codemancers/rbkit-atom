(function() {
  var controlSocket, ipc, zmq;

  ipc = require('ipc');

  zmq = require('zmq');

  controlSocket = zmq.socket('req');

  controlSocket.connect('tcp://127.0.0.1:5556');

  ipc.on('asynchronous-message', function(event, arg) {
    switch (arg) {
      case 'triggerGC':
        console.log('Triggerring GC');
        controlSocket.send('trigger_gc');
        return console.log('Triggerring GC');
    }
  });

}).call(this);
