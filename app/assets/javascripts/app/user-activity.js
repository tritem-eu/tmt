$(function() {
  app._singleton.add('userActivity', function(){
    return {
      addPaginationEvent: function(){
        $('.user-activity-history ul.pagination a').click(function(){$(this).closest('.user-activity-history').addClass('clicked-pagination')});
      },
      addMoreEvent: function(){
        var jPagination = $('.user-activity-history ul.pagination')
        if (jPagination.find('a[data-remote="true"]').length) {
          jPagination.toggleClass('hide');
          var jButtonNext = $('.user-activity-history button').toggleClass('hide');
          jButtonNext.click(function(){
            $(this).toggleClass('hide');
            jPagination.toggleClass('hide');
          })
        }
      },
      replaceWith: function(newContent, requestUrl){
        $('.user-activity-history').replaceWith(newContent);
        window.history.pushState({}, "", requestUrl);
        this.addPaginationEvent();
      },
      isToReplace: function(){
        if ($('.user-activity-history.clicked-pagination').length) {
          return true;
        } else {
          return false;
        }
      }
    }
  });
  app.userActivity.init();
  app.userActivity.addPaginationEvent();
  app.userActivity.addMoreEvent();
});
