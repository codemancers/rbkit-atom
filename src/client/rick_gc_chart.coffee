class @GcChart
  constructor: (element) ->
    @element = element
    @colorPalette = new Rickshaw.Color.Palette(scheme: 'spectrum14')
    @gcStatus = 0

  init: () =>
    @graph = new Rickshaw.Graph(
      element: document.querySelector(@element)
      height: 50
      renderer: 'line'
      series: new Rickshaw.Series.FixedDuration(
        [{name: 'gc'}], @colorPalette, { timeInterval: 1000, maxDataPoints: 15 }
      )
    )
    @renderAxes()

  renderAxes: =>
    new Rickshaw.Graph.Axis.Time(graph: @graph).render()
    new Rickshaw.Graph.Axis.Y.Scaled(
      graph: @graph
      tickFormat: Rickshaw.Fixtures.Number.formatKMBT
      scale: d3.scale.linear()
    ).render()

  gcStart: =>
    @gcStatus = 1

  gcEnd: =>
    @gcStatus = 0

  renderGraph: =>
    @init() unless @graph
    @graph.series.addData(gc: @gcStatus)
    @graph.render()
