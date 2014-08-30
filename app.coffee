ipc = require('ipc')

grapher = new Graph('#chart')

updater = ->
  setTimeout(updater, 1000)
  ipc.send('asynchronous-message', 'sendData')

ipc.on(
  'asynchronous-reply',
  (data) ->
    grapher.addData(data)
)

updater()
