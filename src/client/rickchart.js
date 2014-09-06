(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.Graph = (function() {
    function Graph(element) {
      this.updateGcStats = __bind(this.updateGcStats, this);
      this.renderGraphAndLegend = __bind(this.renderGraphAndLegend, this);
      this.addData = __bind(this.addData, this);
      this.initLegend = __bind(this.initLegend, this);
      this.initHoverDetails = __bind(this.initHoverDetails, this);
      this.renderAxes = __bind(this.renderAxes, this);
      this.init = __bind(this.init, this);
      this.sortAndPickObjectsForRendering = __bind(this.sortAndPickObjectsForRendering, this);
      this.sortSeriesData = __bind(this.sortSeriesData, this);
      this.formatSeriesData = __bind(this.formatSeriesData, this);
      this.element = element;
      this.colorPalette = new Rickshaw.Color.Palette({
        scheme: 'spectrum14'
      });
      this.otherObjects = {};
    }

    Graph.prototype.formatSeriesData = function(seriesData) {
      var count, data, name, _results;
      _results = [];
      for (name in seriesData) {
        count = seriesData[name];
        data = new Object;
        data['name'] = name;
        data[name] = count;
        _results.push(data);
      }
      return _results;
    };

    Graph.prototype.sortSeriesData = function(seriesData) {
      var sortedPairs;
      sortedPairs = _.sortBy(_.pairs(seriesData), function(element) {
        return element[1] * -1;
      });
      return _.object(sortedPairs);
    };

    Graph.prototype.sortAndPickObjectsForRendering = function(seriesData) {
      var atomicData, count, finalData, objectType, otherCount, sortedData;
      sortedData = this.sortSeriesData(seriesData);
      finalData = {};
      otherCount = 0;
      atomicData = 0;
      for (objectType in sortedData) {
        count = sortedData[objectType];
        if (this.otherObjects[objectType]) {
          otherCount += count;
        } else {
          if (atomicData < 15) {
            finalData[objectType] = count;
            atomicData += 1;
          } else {
            otherCount += count;
            this.otherObjects[objectType] = true;
          }
        }
      }
      if (otherCount > 0) {
        finalData["Other"] = otherCount;
      }
      return finalData;
    };

    Graph.prototype.init = function(seriesData) {
      var formattedData, sortedData;
      sortedData = this.sortAndPickObjectsForRendering(seriesData);
      formattedData = this.formatSeriesData(sortedData);
      this.graph = new Rickshaw.Graph({
        element: document.querySelector(this.element),
        height: document.height - 150,
        renderer: 'bar',
        stack: true,
        gapSize: 0.3,
        series: new Rickshaw.Series.FixedDuration(formattedData, this.colorPalette, {
          timeInterval: 1000,
          maxDataPoints: 15
        })
      });
      return this.renderAxes();
    };

    Graph.prototype.renderAxes = function() {
      new Rickshaw.Graph.Axis.Time({
        graph: this.graph
      }).render();
      return new Rickshaw.Graph.Axis.Y.Scaled({
        graph: this.graph,
        tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
        scale: d3.scale.linear()
      }).render();
    };

    Graph.prototype.initHoverDetails = function() {
      return this.hoverDetail = new Rickshaw.Graph.HoverDetail({
        graph: this.graph,
        formatter: function(series, x, y) {
          var colorSwatch, count, name;
          name = '<div class="class-name">Class Name : <strong>' + series.name + '</strong></div>';
          count = '<div class="class-count">Class Count: <strong>' + parseInt(y) + '</strong></div>';
          colorSwatch = '<span class="class-color" style="background-color: ' + series.color + '"></span>';
          return '<div class="class-hoverdetail">' + colorSwatch + '<div class="class-metadata">' + name + count + '</div>' + '</div>';
        }
      });
    };

    Graph.prototype.initLegend = function() {
      var shelving;
      this.legend = new Rickshaw.Graph.Legend({
        graph: this.graph,
        element: document.getElementById('legend')
      });
      shelving = new Rickshaw.Graph.Behavior.Series.Toggle({
        graph: this.graph,
        legend: this.legend
      });
      new Rickshaw.Graph.Behavior.Series.Highlight({
        graph: this.graph,
        legend: this.legend
      });
      this.legend.shelving = shelving;
      return this.graph.series.legend = this.legend;
    };

    Graph.prototype.addData = function(item) {
      var sortedData;
      if (!this.graph) {
        this.init(item);
      }
      sortedData = this.sortAndPickObjectsForRendering(item);
      return this.graph.series.addData(sortedData);
    };

    Graph.prototype.renderGraphAndLegend = function() {
      this.graph.render();
      if (!this.hoverDetail) {
        this.initHoverDetails();
      }
      if (!this.legend) {
        return this.initLegend();
      }
    };

    Graph.prototype.updateGcStats = function(gcStats) {
      var importantFields, key, row, stats, value, _i, _len, _results;
      stats = $('#gcstats tbody');
      stats.empty();
      importantFields = ['count', 'minor_gc_count', 'major_gc_count', 'heap_length', 'heap_eden_page_length', 'heap_used', 'heap_live_slot', 'heap_free_slot', 'heap_swept_slot', 'old_object', 'old_object_limit', 'remembered_shady_object', 'total_allocated_object', 'total_freed_object'];
      _results = [];
      for (_i = 0, _len = importantFields.length; _i < _len; _i++) {
        key = importantFields[_i];
        value = gcStats[key];
        row = "<tr><td>" + key + "</td><td>" + value + "</td></tr>";
        _results.push(stats.append(row));
      }
      return _results;
    };

    return Graph;

  })();

}).call(this);
