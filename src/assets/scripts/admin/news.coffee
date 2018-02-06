define ['require'], (require) ->
  require ['js/app', 'semantic'], () ->
    require ['jquery-ui', 'datepicker_regional_de'], ->
# Datepicker
      $("#date").datepicker
        changeMonth: true,
        changeYear: true,
        dateFormat: "DD, d. MM, yy"
        altField: "#datestamp",
        altFormat: "mm.dd.yy"

    require ['semantic'], () ->
      beforeChange = () ->
        return confirm('Bestätigen, um es zu löschen?')

      onChange = (news_id, toChecked) ->
        console.log(news_id, toChecked)
        $.ajax
          method: 'post',
          url: '/admin/news/active',
          data: {id: news_id, active: toChecked},
          success: (result) ->
            $(this).data('active', toChecked)
          error: (error) ->
            alert('Es tut uns leid! etwas Fehler!')


      $('body.news .ui.toggle.checkbox').checkbox({
        beforeChecked: beforeChange
        beforeUnchecked: beforeChange
        onChecked: () ->
          onChange($(this).data('id'), true)
        onUnchecked: () ->
          onChange($(this).data('id'), false)
      })

      $('#add_attachment').click(() ->
        nextIndex = $('#attachments .fields').length
        $.ajax(
          method: 'get'
          url: '/admin/news/attachment/new/' + nextIndex
          success: (result) ->
            $('#attachments').append(result)
            bindRemoveEvent()
        )
      )

      $('.delete_news').click ->
        id = $(this).data('id')
        $('.ui.basic.modal.confirm_delete').modal(
          onApprove: ->
            $.ajax
              method: 'POST',
              url: '/admin/news/delete',
              data: {id: id},
              success: (result) ->
                $('#news_' + id).remove()
              error: (error) ->
                alert error
        )
          .modal('show')


      bindRemoveEvent = ->
        $('.remove_attach').click ->
          console.log($('#attachments .fields').length)
          if $('#attachments .fields').length <= 1
            return
          else
            fields_id = $(this).data('fields_id')
            $(fields_id).remove()

      bindRemoveEvent()

      return;