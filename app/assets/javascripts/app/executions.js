$(function(){
  app._singleton.init('executions', function(){
    return {
      event: {
        changeObjectTagHeight: function() {
          var objectTag = $('.file-content object')
          if(objectTag.length > 0){
            var contentDocument = $(objectTag[0].contentDocument)
            var innerHeight = contentDocument.innerHeight();
            objectTag.height(innerHeight +20)
            var innerWidth = contentDocument.innerWidth();
            objectTag.width(innerWidth +20)
            $(contentDocument).find('html').css('overflow', 'hidden')
          }
        },
        fullScreen: function() {
          $('.file-content').append('<a class="screen-size"><span class="glyphicon glyphicon-fullscreen"></span></a>');
          $('.screen-size').click(function(){
            $('html').scrollTop(0)
            $('body').scrollTop(0)
            var jFileContent = $('.file-content');
            if (jFileContent.hasClass('full-screen')) {
              $('.file-content-wrapper').append(jFileContent);
              $('body').css({
                overflow: 'auto'
              })
            } else {
              $('#page-wrapper').append(jFileContent);
              $('body').css({
                overflow: 'hidden'
              })
            }
            jFileContent.toggleClass('full-screen')
            if (jFileContent.hasClass('full-screen') ) {
              jFileContent.innerHeight('100%');
            } else {
              jFileContent.innerHeight('500px');
            }

            $(this).find('span').toggleClass('glyphicon-fullscreen glyphicon-screenshot')
          })
        },
        // partial: select_versions
        // User can select 'Take newset versions of all Test Cases' or 'Select versions mannually'
        // When user uses second option then they should see hidden form
        selectVersionsMannually: function(jObjects) {
          //jObject = app.modal.jLastModal()
          if (jObjects == undefined) {
            jObjects = []
          }
          if(jObjects.length > 0){
            jObjects.find('.form-select-test-cases').hide()
            jObjects.find('.execution-select-newest-versions').click(function(){
              jObjects.find('.form-select-test-cases').hide()
            })

            jObjects.find('.execution-select-versions-manually').click(function(){
              jObjects.find('.form-select-test-cases').show()
            })
          }else{
            $('.execution-select-newest-versions').parent('form').addClass('hide')
          }
        },
        showAllVersions: function() {
          var checkbox = $('.select-test-case-versions-show-all-versions');
          checkbox.change(function(){
            jUls = $('.form-select-test-cases .list-style-none > li ul');
            for(var i = 0; i < jUls.length; i++) {
              var jUl = $(jUls[i]);
              var text = jUl.prev().prev().text();
              if ($(this).is(':checked')) {
                jUl.removeClass('hidden');
                jUl.prev().prev().text(text.replace('▸', '▾'));
              } else {
                jUl.addClass('hidden');
                jUl.prev().prev().text(text.replace('▾', '▸'));
              }
            }
          })
        },
        unselectAllVersions: function() {
          $('.select-test-case-versions-unselect-all-versions').change(function(){
            $('.form-select-test-cases .list-style-none > li ul input[type="checkbox"]').each(function(){
              if($(this).parent('li').prev().length == 0) {
                $(this).prop('checked', $('.select-test-case-versions-unselect-all-versions').is(':checked'));
              }
            })
          })
        },
        notAddVersionsUsed: function(){
          $('.select-test-case-versions-not-add-versions-used').change(function(){
            $('.form-select-test-cases .list-style-none > li ul input[type="checkbox"] ~ .counter').each(function(jObject) {
              if ($(this).text() != '0') {
                var is_checked = $('.select-test-case-versions-not-add-versions-used').is(':checked');
                $(this).prev('input[type="checkbox"]').prop('disabled', is_checked);
              }
            })
          })
        },
        showHiddenVersions: function() {
          var jLinks = $('.form-select-test-cases .list-style-none > li > a')
          jLinks.removeAttr('href').removeAttr('data-remote');
          jLinks.css({
            cursor: 'pointer',
            'text-decoration': 'none'
          });
          jLinks.parents('li').find('ul').addClass('hidden')
          jLinks.bind('click', function(){
            $(this).parents('li').find('ul').toggleClass('hidden');
            var text = $(this).text();
            if( text.indexOf('▾') == -1 ) {
              $(this).text(text.replace('▸', '▾'));
            } else {
              $(this).text(text.replace('▾', '▸'));
            }
          });
        },
        keyUpSearchTestCase: function() {
          $('.search-field').bind('keyup', function() {
            var jList = $("ul.list-style-none > li");
            var textSearch = $(this).val();
            var text = ""
            for(var i = 0; i < jList.length; i++ ) {
              if ( $(this).next().is(':checked') ){
                text = $(jList[i]).text()
              } else {
                text = $(jList[i]).children('a').text()
              }
              if(text.indexOf(textSearch) > -1) {
                $(jList[i]).removeClass('hide')
              }else{
                $(jList[i]).addClass('hide')
              }
            }
          })
        },
        showOrDisabledCommentAndDatafiles: function(){
          var showOrDisabledObjects = function() {
            var selectedOptionValue = $('.edit_execution #execution_status option:selected').val()
            var disabledComment = false;
            var disabledDatafile = false;
            var disabledProgress = false;
            if ( ['', 'none', 'executing'].indexOf(selectedOptionValue) > -1 ){
              disabledDatafile = 'disabled'
              disabledComment = 'disabled'
            }else{
              disabledProgress = 'disabled'
            }
            $('.edit_execution #execution_comment').attr('disabled', disabledComment);
            $('.edit_execution #execution_datafiles').attr('disabled', disabledDatafile);
            $('.edit_execution #execution_progress').attr('disabled', disabledProgress);
          }

          $('.edit_execution #execution_status').change(function(){
            showOrDisabledObjects();
          });
          showOrDisabledObjects();
        }
      }
    }
  });
  app.executions.event.fullScreen();
  app.executions.event.unselectAllVersions();
  app.executions.event.selectVersionsMannually();

  if ( $('.form-select-test-cases').length ) {
    app.executions.event.showHiddenVersions();
  }
  if ( $('.executions.show').length ) {
    app.executions.event.showOrDisabledCommentAndDatafiles();
  }
})
