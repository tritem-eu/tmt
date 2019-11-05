$(function(){
  app._singleton.add('sets', function() {
    var activeSet = null;

    return {
      event: {
        clickDropdownMenu: function() {
          clickOnLink = function() {
            set_name = $(this).data('setName')
            app['requestItem']('current_set_name', set_name)
          }
          $('.sets button.set-dropdown').unbind('click', clickOnLink).bind('click', clickOnLink)
        },
        clickShowListTestCases: function(){
          $('.list-sets span.list-sets-test-cases').css('display', 'block');
          $('.list-sets-test-cases').bind('click', function(){
            $('.list-test-cases').animate({width: "toggle", margin: "toggle", padding: "toggle"}, 500, function(){
              $('.list-sets span.list-sets-test-cases').toggleClass('glyphicon-chevron-right glyphicon-chevron-left')
              if($('.list-sets-test-cases').hasClass('glyphicon-chevron-right')) {
                app.resetItem('sets-show-search');
              }else{
                app.localItem('sets-show-search', true);
              }
            })
          })
          if( app.localItem('sets-show-search') == true){
            $('.list-test-cases').css('display', 'block');
            $('.list-sets span.list-sets-test-cases').toggleClass('glyphicon-chevron-right glyphicon-chevron-left')
          }
        },
        keyUpSearchTestCase: function() {
          $('.sets .list-test-cases .form-search input').keyup(function() {
            var items = $(".sets .list-test-cases ul li");
            var textSearch = $(this).val();
            for(var i = 0; i < items.length; i++ ) {
              if($(items[i]).text().indexOf(textSearch) > -1) {
                $(items[i]).removeClass('hide')
              }else{
                $(items[i]).addClass('hide')
              }
            }
          })
        },
        findPlaceForDropdownMenu: function(){
          $('.dropdown').click(function(){
            var jDropdownMenu = $(this).find('.dropdown-menu');
            // For vertical
            var buttonTop = $(this).position().top - $(this).parents('.well').position().top;
            if(jDropdownMenu.height() < buttonTop - 20 ){
              jDropdownMenu.css('top', - jDropdownMenu.height() - 10);
            }else{
              jDropdownMenu.css('top', 15);
            }
            // For horizontal
            var buttonLeft = $(this).position().left - $(this).parents('.well').position().left;
            if(jDropdownMenu.width() < buttonLeft + 10 ){
              jDropdownMenu.css('left', - jDropdownMenu.width() + 30);
            }else{
              jDropdownMenu.css('left', 30);
            }

          })
        }
      },
      addMoveEvent: function(){
        $('.sets .list-test-cases ul.well li').mousedown(function(e){
          var startX = e.pageX;
          var startY = e.pageY;
          $("li.clone").remove();
          jObject = $(this).clone();
          jObject.addClass('clone');
          $(jObject).appendTo('body');
          jObject.css({
            left: startX-10,
            top: startY-10,
            background: '#abcdef',
            'font-size': '20px',
            padding: '15px 30px',
            cursor: 'move',
            'border-radius': '5px',
            'list-style-type': "none",
            position: "absolute"
          });
          $("body").mousemove(function(e){
            jElement = $(document.elementFromPoint(e.pageX - 10, e.pageY - 10))
            $(activeSet).removeClass('active')
            activeSet = app.sets.jGetSet(e.pageX - 10, e.pageY - 10)
            $(activeSet).addClass('active')
            jObject.css("left", e.pageX-10);
            jObject.css("top", e.pageY-10);
          })
          jObject.mouseup(function(e){
            jAHref = $(activeSet).find('.add-test-case-set')
            if (jAHref.length) {
              url = jAHref.attr('href').concat(';test_case_id=' + $(this).attr('value'))
              jAHref.attr('href', url)
              jAHref.click()
              $(activeSet).removeClass('active')
            }
            activeSet = null
            jObject.remove();
            jObject.unbind('mouseup');
            $('body').unbind(' mousemove');
          })
        })
      },
      jGetSet: function(positionX, positionY){
        jResults = $('.sets .list-sets .header')
        for(i=0; i < jResults.length; i++){
          var objectLeft = $(jResults[i]).position().left
          var objectTop = $(jResults[i]).position().top
          if (objectLeft <= positionX && objectLeft + $(jResults[i]).width() >= positionX){
            if (objectTop <= positionY && objectTop + $(jResults[i]).height() >= positionY){
              return $(jResults[i])
            }
          }
        }
      }
    }
  });

  if($('.sets').length) {
    app.sets.init();
    app.sets.addMoveEvent();
    app.sets.event.clickShowListTestCases();
    app.sets.event.keyUpSearchTestCase();
    app.sets.event.findPlaceForDropdownMenu();
    app.sets.event.clickDropdownMenu();
  }
})
