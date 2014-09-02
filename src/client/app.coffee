ipc = require('ipc')

grapher = new Graph('#chart')

updater = ->
  setTimeout(updater, 1000)
  ipc.send('asynchronous-message', 'sendData')

ipc.on(
  'asynchronous-reply',
  (data) ->
    formatForOldData = (newDataFormat) ->
      values = _.map(
        newDataFormat,
        (objData) ->
          [objData.className, objData.count]
      )
      _.object(values)

    if data.length
      oldStyleData = formatForOldData(data)
      grapher.addData(oldStyleData)
      grapher.renderGraphAndLegend()
)

updater()
