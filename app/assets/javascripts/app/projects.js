$(function(){
  app._singleton.add('projects', function() {
    var readGraphData = function(selector) {
      var data = [];
      $(selector + ' .graph-point').each(function(index, object) {
        var jObject = $(object);
        data[index] = {
          year: jObject.data('xvalue'),
          value: jObject.data('yvalue')
        };
      });
      return data;
    }

    return {
      addGraph: {
        testCase: function() {
          if ($('#test-case-graph-last-month .graph-point').length) {
            var data = []
            $('#test-case-graph-last-month .graph-point').each(function(index, object) {
              var jObject = $(object);
              data[index] = {
                year: jObject.data('xvalue'),
                value: jObject.data('yvalue')
              };
            });
            new Morris.Line({
              element: 'test-case-graph-last-month',
              data: readGraphData('#test-case-graph-last-month'),
              xkey: 'year',
              ykeys: ['value'],
              labels: ['Value'],
            });
          }
        },
        testCaseOnresize: function() {
          $(window).resize(function(){
            $('#test-case-graph-last-month svg').remove();
            $('#test-case-graph-last-month .morris-hover').remove();
            app.projects.addGraph.testCase();
          })
        },
        testRun: function() {
          if ($('#test-run-graph-last-month .graph-point').length) {
            new Morris.Line({
              element: 'test-run-graph-last-month',
              data: readGraphData('#test-run-graph-last-month'),
              xkey: 'year',
              ykeys: ['value'],
              labels: ['Value'],
            });
          }
        },
        testRunOnresize: function() {
          $(window).resize(function(){
            $('#test-run-graph-last-month svg').remove();
            $('#test-run-graph-last-month .morris-hover').remove();
            app.projects.addGraph.testRun();
          })
        }
      }
    }
  })

  app.projects.init();
  app.projects.addGraph.testCase();
  app.projects.addGraph.testCaseOnresize();
  app.projects.addGraph.testRun();
  app.projects.addGraph.testRunOnresize();
})

