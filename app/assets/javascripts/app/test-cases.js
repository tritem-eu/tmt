$(function(){
  app._singleton.add('testCases', function(){
    var versions_attributes_0_datafile = null;
    return {
      event: {
        form: {
          // When user upload datafile in a form but comment isn't defined then
          // we need to save datafiled field using this method.
          changeType: function() {
            var fn = function(jObject){
              if (!$('#test_case_type_id').is(jObject)){
                var jObject = $(this)
              }
              var hasFile = jObject.find('option:selected').data('has-file');
              var extension = jObject.find('option:selected').data('extension');

              if (extension == undefined) {
                extension = '*';
              } else {
                extension = '.' + extension;
              }
              var jDataFile = jObject.parents('.form-group').next();
              jDataFile.find('input[type="file"]').attr('accept', extension);
              jDataFile.removeClass('hidden');
              if (hasFile == true) {
                jDataFile.find('input').attr('disabled', false)
              } else {
                jDataFile.find('input').attr('disabled', true)
              }
            }
            $('#test_case_type_id').change(fn);
            fn($('#test_case_type_id'));
          },
          datafile: {
            addOrRemoveRequirementClass: function(){
              var datafileValues = []
              datafileValues.push($("#test_case_versions_attributes_0_comment").val())
              datafileValues.push($("#test_case_versions_attributes_0_datafile").val())
              var row = $('#test_case_versions_attributes_0_comment').parents('.form-group')
              if (datafileValues[0] == '' & datafileValues[1] == ''){
                row.removeClass('required')
              }else{
                row.addClass('required')
              }
            },
            afterChangeDatafileOrComment: function() {
              app.testCases.init().event.form.datafile.addOrRemoveRequirementClass()
              $("#test_case_versions_attributes_0_datafile").change(
                function(){
                  app.testCases.init().event.form.datafile.addOrRemoveRequirementClass()
                }
              )
              $("#test_case_versions_attributes_0_comment").bind("change paste keyup", function(){
                app.testCases.init().event.form.datafile.addOrRemoveRequirementClass()
              })
            }
          },
          saveDatafile: function(){
            $("#test_case_versions_attributes_0_datafile").change(
              function(){
                versions_attributes_0_datafile = $("#test_case_versions_attributes_0_datafile")[0]
              }
            )
          },
          getDatafile: function(){
            if (versions_attributes_0_datafile != undefined) {
              $("#test_case_versions_attributes_0_datafile").replaceWith(versions_attributes_0_datafile)
            }
            app.testCases.init().event.form.saveDatafile();
          },
        },
        versionComment: function(){
          // Automatic generate comment for version
          $("#test_case_version_datafile[type='file']").change(
            function(){
              jComment = $("#test_case_version_comment");
              text = jComment.next().text();
              fileName = $(this).val().replace(/.*(\/|\\)/, '')
              if(jComment.length) {
                // when comment is empty
                if(!jComment.val()){
                  jComment.val(text + ": " + fileName)
                }else{
                  // when user doesn't add the custom comment
                  if(jComment.val().indexOf(text + ":") == 0){
                    jComment.val(text + ": " + fileName)
                  }
                }
              }

              jName = $('#test_case_name');
              // when name is empty
              if(jName.length != 0 && jName.val() == ''){
                array = fileName.split('.');
                if ( array.length > 1 ) {
                  array.pop();
                }
                jName.val(array.join('.'))
              }
            }
          )
        },
        clickFacetsName: function(){
          app.testRuns.init().event.clickFacetsName();
        },
        changeFacetsCheckbox: function() {
          app.testRuns.init().event.changeFacetsCheckbox();
        },
        changeCheckbox: function() {
          $('.select-all').click(function(){
            if( $(this).is(':checked') ) {
              $(this).parents('table').find('.check-test-case').not(':checked').not(":disabled").click();
            } else {
              $(this).parents('table').find('.check-test-case:checked').not(":disabled").click();
            }
          })
          $("input.check-test-case[type='checkbox']").change(function() {
            jCheckBox = $(this).clone();
            jCheckBox.addClass('hidden');
            jForm = $("form.select-test-run");
            jForm.find("input[value='" + jCheckBox.val() +"']").remove();
            if(jCheckBox.is(':checked') == true) {
              jForm.prepend(jCheckBox)
            }
            if(jForm.find("input[type='checkbox']").length) {
              jForm.removeClass('hidden')
            }else{
              jForm.addClass('hidden')
            }
            var jCheckedCheckboxes = $(this).parents('table').find('.check-test-case:checked[type="checkbox"]').not(':disabled');
            var jCheckboxes = $(this).parents('table').find('.check-test-case[type="checkbox"]').not(':disabled');

            var isChecked = (jCheckboxes.size() == jCheckedCheckboxes.size());
            $('.select-all').prop('checked', isChecked);
          })
        },
      }
    }
  })

  if($('form.select-test-run').length) {
    app.testCases.init().event.changeCheckbox();
  }

  if($('.test-cases, .sets').length){
    //file search in test-run
    app.testCases.init().event.versionComment();
    app.testCases.init().event.clickFacetsName();
    app.testCases.init().event.changeFacetsCheckbox();
  }
})
