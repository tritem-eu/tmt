// http://addyosmani.com/resources/essentialjsdesignpatterns/book/
var app;

app = app || {}
app._config.array();
app['version'] = '0.0.1';
app['_ajax'] = {
  event: {
    lock: function() {
      $("a[data-remote='true']").unbind('ajax:beforeSend')
      $("a[data-remote='true']").bind('ajax:beforeSend', function() {
        var gradient = '0.2';
        if ( $(this).hasClass('ajax-no-background') ) {
          gradient = '0.0'
        }
        $('body').append("<div class='ajax-locker'></div>")
        $('.ajax-locker').css({
          width: '100%',
          height: '100%',
          position: 'fixed',
          top: '0',
          left: '0',
          background: 'rgba(0, 0, 0, ' + gradient + ')',
          'z-index': '10000'
        })
        $("<span class='load-icon-50' style='top: 50%; left: 50%; position: absolute'></span>").appendTo('.ajax-locker')
      });

      $(document).unbind('ajaxComplete');
      $(document).unbind('ajaxError');
      $(document).unbind('ajaxSuccess');
      $(document).bind('ajaxComplete', function() {
        $('.ajax-locker').remove();
        app._ajax.event.lock();
      });
      $(document).ajaxError(function(xhr, ajaxOptions, thrownError) {
        $('.ajax-locker').remove();
        app._ajax.event.lock();
        if(ajaxOptions.status == 500) {
          app.modal.add(
            "<div class='modal col-lg-9' data-signature='error 500'>" +
              "<div class='modal-content'>" +
                "<div class='modal-header'><button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button><h3>HTTP Error 500</h3></div>"+
                "<div class='modal-body'><div class='col-lg-9 col-lg-offset-1'><br /><br /><h3><i class='fa fa-exclamation' style='font-size: 40px;'></i> We're sorry, but something went wrong (500)</h3><br /><p>If you are the application owner check the logs for more information.</p><br /><br /><br /></div><div class='clear-both'></div></div>" +
                "<div class='modal-footer hide'></div>" +
              "</div>"+
            "</div>"
          , function(){
            $('.modal .modal-body pre').html(ajaxOptions.responseText);
          })
        }
        if(ajaxOptions.status == 404) {
          app.modal.add(
            "<div class='modal col-lg-9' data-signature='error 404'>" +
              "<div class='modal-content'>" +
                "<div class='modal-header'><button type='button' class='close' data-dismiss='modal' aria-hidden='true'>&times;</button><h3>HTTP Error 404</h3></div>"+
                "<div class='modal-body'><div class='col-lg-9 col-lg-offset-1'><br /><br /><h3><i class='fa fa-exclamation' style='font-size: 40px;'></i> The page you were looking for doesn't exist (404)</h3><br /><p>You may have mistyped the address or the page may have moved.</p><br /><br /><br /></div><div class='clear-both'></div></div>" +
                "<div class='modal-footer hide'></div>" +
              "</div>"+
            "</div>"
          , function(){
            $('.modal .modal-body pre').html(ajaxOptions.responseText);
          })
        }
      });
      $(document).bind('ajaxSuccess', function() {
        $('.ajax-locker').remove();
        app._ajax.event.lock();
      });
    }
  }
}

$(function(){
  app['_uploadFile'] = function() {
    var basket = [];
    return {
      event: function() {
        $('input[type="file"]').unbind()
        $('input[type="file"]').change(function() {
          basket.push(this);
        })
      },
      basket: basket
    }
  }();
  app._uploadFile.event();

  app['_onlyOneClick'] = function() {
  var addEvent = function(event) {
    if ($(this).hasClass('only-one-click-used') ) {
      $(this).attr('disabled', 'disabled');
    }
    $(this).addClass('only-one-click-used');
  };
  $('.only-one-click:not([data-confirm]):not(.only-one-click-activated)').bind('click', addEvent);
  $('.only-one-click:not([data-confirm]):not(.only-one-click-activated)').addClass('only-one-click-activated');
  };

  app._onlyOneClick();

  // When user don't select option then button of form will be disabled
  // that this method works you should add 'button-active-after-select' class to select widget in modal window
  app['buttonActiveAfterSelect'] = function(){
    var jSelect = $('.button-active-after-select');
    if( jSelect.length ) {
      var jButton = jSelect.parents('.modal').find('.in-modal-footer');
      if ( jSelect.val() == "" ) {
        jButton.addClass('disabled');
      }
      jSelect.change(function(){
        if(jSelect.val() == "") {
          jButton.addClass('disabled');
        } else {
          jButton.removeClass('disabled');
        }
      })
    }
  }

  app['inputCounter'] = function(){
    jInputs = $('[class*="js-input-counter-"]');

    for(var i=0; i< jInputs.length; i++){
      if (!$(jInputs[i]).hasClass('js-used')) {
        var maxNameLength = undefined;

        $(jInputs[i]).attr('class').split(' ').map(function(item){
          if(!item.indexOf('js-input-counter-')){
            maxNameLength = item.split('-').last();
          }
        })
      }
    }
  }

  app._bootstrap.inputDownCounter();

  $('span.glyphicon-zoom-in').click(function(){
    $(this).toggleClass('glyphicon-zoom-out glyphicon-zoom-in')
    $(this).prev().toggleClass('crop non-crop')
  })

  app._bootstrap['activatePopover'] = function(){
    $('a[data-toggle="popover"]').popover({html: true, trigger: 'hover'})
  }
  app._bootstrap.activatePopover();

  app._bootstrap['hiddenDropdownMenu'] = function(){
    $('.dropdown-menu').click(function(){
      $(this).parents('.dropdown').click();
    });
  }
  app._bootstrap.hiddenDropdownMenu();

  // User can use with dropdownMenu without javascript
  app._bootstrap['dropdownMenu'] = function(){
    $('.dropdown-menu-hover').removeClass('dropdown-menu-hover');
  }
  app._bootstrap.dropdownMenu();

  app['_back'] = function(){
    $('.link-back').removeClass('disabled');
    $('.link-back a').attr('href', 'javascript:window.history.back()')
  }

  app._back()
  app['_forward'] = function(){
    window.history.forward();
  }

  app['localItem'] = function(name, value) {
    try {
      if(value != undefined) {
        localStorage[name] = JSON.stringify(value);
      }
      return JSON.parse(localStorage[name]);
    } catch (e) {
      return undefined
    }
  }

  app['sessionItem'] = function(name, value) {
    name = String($('head').data('user_id') || "") + "_" + name;
    try {
      if(value != undefined) {
        sessionStorage[name] = JSON.stringify(value);
      }
      return JSON.parse(sessionStorage[name]);
    } catch (e) {
      return undefined
    }
  }

  app['requestItem'] = function(name, value) {
    if(app.requestStorage == undefined) {
      app.requestStorage = {}
    }

    name = String($('head').data('user_id') || "") + "_" + name;
    try {
      if(value != undefined) {
        app.requestStorage[name] = JSON.stringify(value);
      }
      return JSON.parse(app.requestStorage[name]);
    } catch (e) {
      return undefined
    }
  }

  app['resetItem'] = function(name) {
    try {
      localStorage[name] = undefined;
    } catch (e) {
      console.log('No Web Storage support')
    }
  }

  app['onlyForJS'] = function(){
    $('.only-for-js').removeClass('only-for-js');
  }
  app.onlyForJS();

  app['removeHideWhenJsIsDisabled'] = function(){
    $('.hide-when-js-is-disabled').removeClass('hide-when-js-is-disabled');
  }
  app.removeHideWhenJsIsDisabled();

  app['removeHideWhenJsIsActive'] = function(){
    $('.hide-when-js-is-active').addClass('hide');
  }
  app.removeHideWhenJsIsActive();

  app['addNonselectableAttr'] = function(){
    $('.nonselectable').find('*').andSelf().attr('unselectable', 'on');
  }
  app.addNonselectableAttr();

})

app._ajax.event.lock();
