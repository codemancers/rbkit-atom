ipc = require('ipc')

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
