// Documentation: http://open-services.net/bin/view/Main/OslcCoreSpecification#Delegated_User_Interface_Dialogs

$(function(){
  app._singleton.add('oslc', function() {
    return {
      respondWithPostMessage: function(response) {
        (window.parent | window).postMessage("oslc-response:" + response, "*");
      },
      uiProvider: function() {
        return {
          urlSearchForm: function(){
            this.addProtocolToURL();
            return $('form.search-form').attr('action');
          },
          addProtocolToURL: function(){
            if (!$('form').attr('action').match('#oslc-core-')) {
              urlSearchForm = $('form.search-form').attr('action')
              $('form.search-form').attr('action', urlSearchForm + window.location.hash)
            }
          },
          postMessage: function(response){
            if (window.location.hash == '#oslc-core-postMessage-1.0') {
              this.addProtocolToURL();
              window.parent.postMessage(response, "*");
            }
          },
          windowName: function(response){
            if (window.location.hash == '#oslc-core-windowName-1.0') {
              this.addProtocolToURL();
              var returnURL = window.name;
              window.name = response;
              window.location = returnURL;
            }
          },
          // Example:
          //    app.oslc.uiProvider.messageEvent(function(e){
          //      $('h1').html(e.data)
          //    })
          messageEvent: function(fn){
            window.addEventListener("message", fn, false);
          }
        }
      }(),
      uiConsumer: function(){
        return {
          listenRespond: function(fn){
            window.addEventListener("message", fn, false);
          },
          addFrame: function(params) {
            var pickerURL = params['pickerURL']
            var returnURL = params['returnURL']

            var frame = document.createElement('iframe');
            if (ie > 0) {
              frame = document.createElement('<iframe name=\'' + returnURL + '\'>');
            } else {
              frame = document.createElement('iframe');
              frame.name = returnURL;
            }

            frame.src = pickerURL + params['protocol']; //'#oslc-core-postMessage-1.0';
            $(frame).css({
              border: '1px solid #eeeeee',
              width: '430',
              height: '400',
              scroll: 'auto'
            });
            $(frame).attr('id', 'oslc-iframe')
            $(params['appendTo']).append(frame);
            $(frame).insertAfter($(params['insertAfter']))
            // Step #3: listen for onload events on the iframe
            var ie = window.navigator.userAgent.indexOf("MSIE");
            if (ie > 0) {
            //   frame.attachEvent("onLoad", onFrameLoaded);
            } else {
            //   frame.onload = onFrameLoaded;
            }

   //      function onFrameLoaded() {
   //         try { // May throw an exception if the frame's location is still a different origin
   //           // Step #4: when frame's location is equal to the Return URL 
   //           // then read response and return.
   //           if (frame.contentWindow.location == returnURL) {
   //             var message = frame.contentWindow.name;
   //             destroyFrame(frame);
   //             handleMessage(message);
   //           }

   //         } catch (e) {
   //            // ignore: access exception when trying to access window name
   //         }
   //      }

          },
          windowNameProtocol: function(){}
        }
      }()
    }
  })

  // Provider Resposibility
  //if($('.oslc-selection-dialog').length) {
    app.oslc.init();

    var response = $('[data-response]').data('response');
    app.oslc.uiProvider.postMessage(response);
    app.oslc.uiProvider.windowName(response);
  //}
})
