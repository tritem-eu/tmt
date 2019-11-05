$(function(){
  app._singleton.add('testRuns', function(){
    return {
      event: {
        clickFacetsName: function(){
          // Automatic generate comment for version
          $(".facets-name").css('cursor', 'pointer')
          $(".facets-name").unbind('click').click(
            function(){
              jCheckbox = $(this).prev();
              jCheckbox.click();
            }
          )
        },
        changeFacetsCheckbox: function(){
          $('.facets-checkbox').addClass('hide')
          $('.facets-checkbox').change(function(){
            $(this).parents('form.search-form').find('button').click();
          })
        }
      }
    }
  })

  if($('.test-runs, .sets').length){
    app.testRuns.init().event.clickFacetsName();
    app.testRuns.init().event.changeFacetsCheckbox();
  }
})
