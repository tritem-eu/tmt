$(function() {
  app._singleton.add('user', function(){
    return {
      event: {
        showHidePassword: function() {
          $('#user_switch_password').change(function(){
            if( this.checked ){
              $('.js-user-password').removeClass('hide');
              app['sessionItem']('user_switch_password', true);
            }else{
              $('.js-user-password').addClass('hide');
              app['sessionItem']('user_switch_password', false);
            }
          });
        }
      }
    }
  });

  if( $('#user_switch_password').length ) {
    if(app['sessionItem']('user_switch_password') != true) {
      $('.js-user-password').addClass('hide');
      $('#user_switch_password').bootstrapSwitch('setState',false)
    }else {
      $('#user_switch_password').bootstrapSwitch('setState',true)
    }
    app.user.init().event.showHidePassword();
  }
});
