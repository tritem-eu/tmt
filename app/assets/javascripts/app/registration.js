$(function() {
  app._singleton.add('registration', function(){
    return {
      event: {
        showHidePassword: function() {
          var fn = function(){
            if( this.checked ){
              $('.js-user-password').removeClass('hide');
              app['sessionItem']('registration_switch_password', true);

            }else{
              $('.js-user-password').addClass('hide');
              app['sessionItem']('registration_switch_password', false);
            }
          };
          $('.registration-switch-password input').bind('change', fn)
        }
      }
    }
  });

  if( $('.registration-switch-password').length ) {
    if(app['sessionItem']('registration_switch_password') != true) {
      $('.js-user-password').addClass('hide');
      $('.registration-switch-password input').bootstrapSwitch('setState',false)
    }else {
      $('.registration-switch-password input').bootstrapSwitch('setState',true)
    }
    $('.registration-switch-password').removeClass('hide');
    app.registration.init().event.showHidePassword();
  }
});
