ipc = require('ipc')

objCountUpdater = ->
  setTimeout(objCountUpdater, 1000)
  ipc.send('asynchronous-message', 'sendObjCount')

gcStatsUpdater = ->
  setTimeout(gcStatsUpdater, 3000)
  ipc.send('asynchronous-message', 'sendGcStats')

# updates heap charts by getting those keys out of GC Stats
heapChartsUpdater = ->
  setTimeout(heapChartsUpdater, 1000)
  ipc.send('asynchronous-message', 'sendHeapData')

ipc.on(
  'heapData',
  (data) ->
    return if _.isEmpty(data)
    Rbkit.updateHeapChart(data)
)

ipc.on(
  'gcStats',
  (data) ->
    return if _.isEmpty(data)
    Rbkit.updateGcStats(data)
)

ipc.on(
  'objCount',
  (data) ->
    totalObjectCountArray = _.map(
      data,
      (dataObject) ->
        dataObject.count
    )
    totalObjectCount = _.reduce(
      totalObjectCountArray,
      (memo, num) -> memo + num
      0
    )
    Rbkit.updateLiveObjectsChart({'Heap Objects': totalObjectCount})
)

objCountUpdater()
gcStatsUpdater()
heapChartsUpdater()
