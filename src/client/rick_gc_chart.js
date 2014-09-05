(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.GcChart = (function() {
    function GcChart(element) {
      this.renderGraph = __bind(this.renderGraph, this);
      this.gcEnd = __bind(this.gcEnd, this);
      this.gcStart = __bind(this.gcStart, this);
      this.renderAxes = __bind(this.renderAxes, this);
      this.init = __bind(this.init, this);
      this.element = element;
      this.colorPalette = new Rickshaw.Color.Palette({
        scheme: 'spectrum14'
      });
      this.gcStatus = 0;
    }

    GcChart.prototype.init = function() {
      this.graph = new Rickshaw.Graph({
        element: document.querySelector(this.element),
        height: 50,
        renderer: 'line',
        series: new Rickshaw.Series.FixedDuration([
          {
            name: 'gc'
          }
        ], this.colorPalette, {
          timeInterval: 1000,
          maxDataPoints: 15
        })
      });
      return this.renderAxes();
    };

    GcChart.prototype.renderAxes = function() {
      new Rickshaw.Graph.Axis.Time({
        graph: this.graph
      }).render();
      return new Rickshaw.Graph.Axis.Y.Scaled({
        graph: this.graph,
        tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
        scale: d3.scale.linear()
      }).render();
    };

    GcChart.prototype.gcStart = function() {
      return this.gcStatus = 1;
    };

    GcChart.prototype.gcEnd = function() {
      return this.gcStatus = 0;
    };

    GcChart.prototype.renderGraph = function() {
      if (!this.graph) {
        this.init();
      }
      this.graph.series.addData({
        gc: this.gcStatus
      });
      return this.graph.render();
    };

    return GcChart;

  })();

}).call(this);
