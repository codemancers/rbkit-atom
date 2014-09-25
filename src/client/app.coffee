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

ipc.on(
  'gc_start',
  (timestamp) ->
    dateFromTimestamp = new Date(timestamp)
    Rbkit.gcStarted(dateFromTimestamp)
)

ipc.on(
  'gc_end',
  (timestamp) ->
    dateFromTimestamp = new Date(timestamp)
    Rbkit.gcEnded(dateFromTimestamp)
)

objCountUpdater()
gcStatsUpdater()
heapChartsUpdater()

startProfilingButton = $('#start-profiling')
stopProfilingButton = $('#stop-profiling')
gcTriggerButton = $('#trigger-gc')

triggerGC =  (event) ->
  event.preventDefault()
  ipc.send('asynchronous-message', 'triggerGC')

startProfiling = (event) ->
  event.preventDefault()
  ipc.send('asynchronous-message', 'startProfiling')
  startProfilingButton.hide()
  stopProfilingButton.show()

stopProfiling = (event) ->
  event.preventDefault()
  ipc.send('asynchronous-message', 'stopProfiling')
  startProfilingButton.show()
  stopProfilingButton.hide()

$('#trigger-gc').click(triggerGC)
$('#start-profiling').click(startProfiling)
$('#stop-profiling').click(stopProfiling)
