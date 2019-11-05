$(function() {
  app._config.array();
  app._singleton.init('modal', function(){
    var currentId = 0;

    var setLastModalScrollPosition = function(){
      var jLastModal = this.jLastModal();
      if (jLastModal.length){
        var scrollTop = jLastModal.attr('data-scroll-top');
        $('.modal-backdrop').scrollTop(scrollTop);
      }
    }

    var jLastModal = function(){
      return $('.modal[data-id="' + currentId + '"]');
    }

    var onlyRemoveLast = function(){
      var jLastModal = $('.modal[data-id="' + currentId + '"]');
      currentId -= 1;
      if(currentId < 0) {
        currentId = 0;
      }
      jLastModal.remove();
      if (currentId != 0) {
        $('.modal[data-id="' + currentId + '"]').find('.modal-content').css({opacity: '1'})
      }
    }

    var removeLast = function(){
      var jLastModal = $('.modal[data-id="' + currentId + '"]');
      currentId -= 1;
      if(currentId < 0) {
        currentId = 0;
      }
      jLastModal.remove();
      if (currentId == 0) {
        $('.modal-backdrop').animate({opacity: '0'}, 500, function(){
          $('.modal-backdrop').remove();
          $('body').css('overflow', 'auto');
          $('body').css('margin-right', '0')
        })
      } else {
        $('.modal[data-id="' + currentId + '"]').find('.modal-content').css({opacity: '1'})
      }
      app.modal.setLastModalScrollPosition();
    }

    var removeAll = function(jObject){
      $('.modal-backdrop').animate({opacity: '0'}, 500, function(){
        $('.modal').remove();
        $('.modal-backdrop').remove();
        $('body').css('overflow', 'auto');
        $('body').css('margin-right', '0')
        currentId = 0;
      })
    }

    var saveLastModalScrollPosition = function(){
      var jLastModal = this.jLastModal();
      if (jLastModal.length){
        var scrollTop = $('.modal-backdrop').scrollTop();
        jLastModal.attr('data-scroll-top', scrollTop);
      }
    }



    return {
      addButtonToFooter: function(){
        var jFooter = $('.modal .modal-footer.hide');
        jFooter.css('margin', '0');
        var jButtons = jFooter.parents('.modal').find('.in-modal-footer')
        jFooter.removeClass("hide");
        var jButtonBack = $("<button class='btn btn-default'> <span class='glyphicon glyphicon-arrow-left'></span> Back</button>");
        jButtonBack.bind('click', function(){
          removeLast();
        })
        jFooter.append(jButtonBack);
        for(i = 0; i < jButtons.length; i++){
          jButton = $(jButtons[i]);
          jButton.attr('data-twin-id', app._uuid());

          var jButtonClone = jButton.clone();
          jButton.addClass('hide');
          jFooter.append(jButtonClone);
          jButtonClone.click(function(){
            $(".modal .modal-body .in-modal-footer[data-twin-id=" + $(this).data('twin-id') + "]").click();
          })
        }
      },
      event: {
        // Removes modal view
        clickClose: function(){
          $('.modal .close').click(function(e){
            removeAll();
          })
          $('.modal-backdrop').click(function(e){
            if (e.target == $(this)[0] )
              removeAll();
          })
        },
        move: function() {
          $(".modal").mouseover(function(e){
            var offsetTop = e.clientY - $(".modal").position().top - parseInt($('.modal').css('margin-top'));
            var offsetLeft = e.clientX - $(".modal").position().left;

            if(e.target == $('.modal-header')[0] || e.target == $('.modal-footer')[0] || e.target == $('.modal-body')[0]){
              e.target.style.cursor = 'move'
            }else{
              e.target.style.cursor = 'default'
            }
          })

          $(".modal").mousedown(function(e){

            var offsetTop = e.clientY - $(".modal").position().top - parseInt($('.modal').css('margin-top'));
            var offsetLeft = e.clientX - $(".modal").position().left;

            if ( $('.modal-content').width() - 20 < offsetLeft ) // omit scrollbar
              return 0;

            if ( e.button != 0 ) // only left button
              return 0;

            if(e.target == $('.modal-header')[0] || e.target == $('.modal-footer')[0] || e.target == $('.modal-body')[0]){
              $('.bootstrap-datetimepicker-widget').css('display', 'none');

              e.stopPropagation();
              $(".modal").unbind("mousemove");
              $(".modal").unbind("mouseup");
              $('body').append("<div class='modal-pulpit'></div>")
              $('.modal-pulpit').css({'height': '100%', 'width': '100%', 'cursor': 'move', 'z-index': "2000", 'position': "fixed", 'top': "0"})
              var jModal = $(this);
              $('.modal-pulpit').mousemove(function(e){
                var newTop = e.pageY;
                var newLeft = e.pageX;
                jModal.offset({top: newTop - offsetTop})
                jModal.offset({left: newLeft - offsetLeft})
              })

              $(".modal-pulpit").mouseup(function(e){
                $('.modal').unbind("mousemove");
                $('.modal').unbind("mouseup");
                $('.modal-pulpit').remove();
              })
            }
          })
          $(".modal-backdrop").mousemove(function(e){
            $(".modal").unbind("mousemove")
            $(".modal").unbind("mouseup")
          })
        }
      },
      removeAll: removeAll,
      removeLast: removeLast,
      onlyRemoveLast: onlyRemoveLast,
      jLastModal: jLastModal,
      centerWindow: function() {
        var modalHeight = $('.modal-content').height();
        if ($(window).height() > modalHeight + 100) {
          var diffHeight = $(window).height() - modalHeight;
          $('.modal').css('margin-top', $('.modal-backdrop').scrollTop() + diffHeight*0.4)
          $('.modal').css('margin-bottom', '50px')
        } else {
          $('.modal').css('margin', '50px 0')
        }
        $('.modal').css('height', modalHeight + 50)
        var windowLeft = ($(window).width() / 2) - (app.modal.jLastModal().width()/2);
        $('.modal').css('left', windowLeft);
        $('.modal').css('margin-left', 0);
        $('.modal').css('margin-right', 0);
      },
      refreshLinks: function() {
        $('[data-toggle="modal"]').click(function(){
          if($('.modal-backdrop').length == 0){
            $('body').append("<div class='modal-backdrop'></div>")
          }
        })
      },
      saveLastModalScrollPosition: saveLastModalScrollPosition,
      setLastModalScrollPosition: setLastModalScrollPosition,
      add: function(content, fn) {
        this.saveLastModalScrollPosition();
        var bodyWidth = $('body').width();
        jContent = $(content)
        currentId++;
        $('body').css('overflow', 'hidden');

        if($('.modal-backdrop').length == 0){
          $('body').append("<div class='modal-backdrop'></div>")
        }
        $('.modal-content').css('opacity', '0');
        $('.modal-backdrop').append(jContent.attr('data-id', currentId)).css('overflow', 'auto');
        $('.modal').css({
          display: 'block',
          position: 'absolute',
          top: '0'
        });
        $('.modal').find('h3').css('margin-top', '0');
        $('.modal').find('.modal-footer').css('padding', '10px 15px');
        this.addButtonToFooter();
        this.centerWindow();
        this.event.clickClose();
        this.event.move();
        app._bootstrap.inputDownCounter();
        app.bootstrapSwitch.add();
        app.buttonActiveAfterSelect();
        app._onlyOneClick();
        $('body').css('overflow', 'hidden');
        $('body').css('margin-right', ($('body').width()-bodyWidth));
        if (typeof fn === 'function') {
          fn();
        }
        app._bootstrap.activatePopover();
        $('.modal-backdrop').scrollTop(0);
        this.saveLastModalScrollPosition();
        app.removeHideWhenJsIsDisabled()
      },
      currentId: function() {return currentId}
    }
  });

  app.modal.refreshLinks()

  $(window).resize(function() {
    app.modal.centerWindow();
  })
});
