ipc = require('ipc')

grapher = new Graph('#chart')
gcGrapher = new GcChart('#gc-chart')

objCountUpdater = ->
  setTimeout(objCountUpdater, 1000)
  ipc.send('asynchronous-message', 'sendObjCount')

gcStatsUpdater = ->
  setTimeout(gcStatsUpdater, 3000)
  ipc.send('asynchronous-message', 'sendGcStats')

ipc.on(
  'gcStats',
  (data) ->
    return if _.isEmpty(data)
    grapher.updateGcStats(data)
)

ipc.on(
  'objCount',
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
      gcGrapher.renderGraph()
)

ipc.on(
  'gc_start',
  (message) ->
    gcGrapher.gcStart()
)

ipc.on(
  'gc_end',
  (message) ->
    gcGrapher.gcEnd()
)

objCountUpdater()
gcStatsUpdater()
