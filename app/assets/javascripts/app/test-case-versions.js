$(function() {
  app.testCaseVersions = {
    checkProgress: function() {
      var progress = setInterval(function(){
        var jProgresses = $('a .load-icon');
        if (jProgresses.length) {
          for (var i = 0; i < jProgresses.length; i++) {
            if (i == 0) {
              if (!$(jProgresses[i]).hasClass('progress-lock')){
                var jLink = jProgresses.parent("a");
                if (jLink.length) {
                  jProgresses.addClass('progress-lock');
                  jLink.unbind('ajax:beforeSend');
                  jLink.click();
                }
              }
            }
          }
        } else {
          clearInterval(progress);
        }
      }, 1000);
    }
  }

  if ($(".test-cases, .test-case-versions.show").length) {
    app.testCaseVersions.checkProgress();
  }

});
