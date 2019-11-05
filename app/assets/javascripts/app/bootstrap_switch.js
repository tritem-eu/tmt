$(function(){
  app._singleton.init('bootstrapSwitch', function(){
    return {
      add: function(){
        $(".switch-small").bootstrapSwitch();
        $(".switch-normal").bootstrapSwitch();
        $(".has-switch").next().addClass('hidden');
        $('.has-switch label').click(function(){
          $(this).unbind('click');
          $(this).parents('.has-switch').next().click();
        });
      }
    }
  })
  app.bootstrapSwitch.add();
})
