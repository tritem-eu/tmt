$(function() {
  app._singleton.init('dateTimePicker', function(){
    return {
      hiddenDateTimePicker: function() {
        $('.bootstrap-datetimepicker-widget').css('display', 'none');
      },
      addDate: function() {
        // For input of datepicker
        $('.datetimepicker.js-date').datetimepicker({
          format: 'yyyy-MM-dd hh:mm:ss',
          pickTime: false,
        }).on('changeDate', function(e){
          $('.bootstrap-datetimepicker-widget').css('display', 'none');
        });
      },
      addDateTime: function() {
        // For input of datepicker
        $('.datetimepicker.js-datetime').datetimepicker({
          format: 'yyyy-MM-dd hh:mm:ss'
        }).on('changeDate', function(e){
          if($(this).find('.glyphicon-calendar').length == 1){
            $('.bootstrap-datetimepicker-widget').css('display', 'none');
          }
        });
      },
      add: function() {
        this.addDate();
        this.addDateTime();
        $('.bootstrap-datetimepicker-widget .picker-switch').hover(
          function(){$(this).css('background', '#eee')},
          function(){$(this).css('background', '#fff')}
        )
      }
    }
  });
  app.dateTimePicker.add();
});
