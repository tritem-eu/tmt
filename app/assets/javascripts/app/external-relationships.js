$(function(){
  app._singleton.add('externalRelationships', function(){
    var setHiddenField = function() {
      jKindUrl = $('#external_relationship_kind_url')
      jKindRqId = $('#external_relationship_kind_rq_id')
      if( jKindUrl.is(':checked') == true ) {
        $('#external_relationship_url').removeAttr('disabled')
        $('#external_relationship_value').removeAttr('disabled')
        $('#external_relationship_rq_id').attr('disabled', 'disabled')
      }else{
        $('#external_relationship_rq_id').removeAttr('disabled')
        $('#external_relationship_url').attr('disabled', 'disabled')
        $('#external_relationship_value').attr('disabled', 'disabled')
      }
    }
    return {
      event: {
        changeKind: function(){
          setHiddenField()
          $('#external_relationship_kind_url, #external_relationship_kind_rq_id').click(function(){
            setHiddenField()
          })

        }
      }
    }
  })

  if($('#external_relationship_kind_url').length) {
    app.externalRelationships.init().event.changeKind();
  }

})
