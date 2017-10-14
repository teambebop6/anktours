define ['require'], (require) ->
  require ['js/app'], () ->
    require ['jquery-ui', 'datepicker_regional_de'], ->
# Datepicker
      $("#date").datepicker
        changeMonth: true,
        changeYear: true,
        dateFormat: "DD, d. MM, yy"
        altField: "#datestamp",
        altFormat: "mm.dd.yy"


    initializeImageActions = () ->
# IMAGE ACTIONS
# Move image
      $('.move-up').click ->
        move($(this).data('id'), true)
      $('.move-down').click ->
        move($(this).data('id'), false)
      # Delete image
      $('.deleteImage').click ->
        deleteImage($(this).data('id'))

    initializeImageActions()

    move = (id, up) ->
      list = $('#images .galery_image')
      el = document.getElementById(id)
      currentIndex = list.index(el)

      if up && currentIndex > 0
        $(el).insertBefore(list.get(currentIndex - 1))
      else if !up && currentIndex < list.length - 1
        $(list.get(currentIndex + 1)).insertBefore(list.get(currentIndex))
      else
        console.log "Element cannot be moved in this direction."

    deleteImage = (filename) ->
      id = $('#galery_id').val()

      $('.ui.basic.modal.confirm_delete').modal(
        onApprove: () ->
          $.ajax
            method: 'post',
            url: '/admin/galeries/deleteImage',
            data: {id: id, filename: filename},
            success: (result) ->
              if result.status == 200
                $('div[id="' + filename + '"]').hide()
      )
      .modal('show')

    # Delete galery
    $('.delete-galery').click ->
      id = $(this).attr('id')
      id = id.substring(7, id.length)
      $('.ui.basic.modal.confirm_delete').modal(
        onApprove: ->
          $.ajax
            method: 'POST',
            url: '/admin/galeries/delete',
            data: {id: id},
            success: (result) ->
              if result.status == 200
                $('#galery_' + id).hide()
      )
      .modal('show')

    require ['js/fileupload'], () ->
      console.log "Initialized fileupload"
      $('#fileupload').fileupload(
        url: '/uploads'
        dataType: 'json'
        formData: {galery_id: $('#galery_id').val()}
        sequentialUploads: true
        done: (e, data) ->
          $.each(data.result.files, (index, file) ->
            console.log file
            $.ajax(
              type: "post"
              url: '/admin/galeries/renderThumbView'
              data:
                image: {
                  id: file.id
                  fileName: file.name
                  title: file.name
                }
              success: (result) ->
                $(result).appendTo('#images')
                initializeImageActions()
            )
          )
        fail: (data) ->
          alert("Fail!")
        progressall: (e, data) ->
          progress = parseInt(data.loaded / data.total * 100, 10)
          $('#progress .progress-bar').css(
            'width',
            progress + '%'
          )
      )

    getFormData = (arr) ->
      data = {}
      $.each(arr, (index, field) ->
        data[field.name] = field.value
      )
      return data

    $('.button.submit_changes').click (e) ->
      $.ajax(
        type: 'post'
        url: '/admin/galeries/modify'
        data:
          galery_id: $('#galery_id').val()
          info: getFormData($('#galery-info').serializeArray())
          images:
            data: $('#images_info').serializeArray()
            sort: $('#images .galery_image').map(() -> return this.id).get()
        success: (result) ->
          if result.status == 200
            $('.save-succeeded').fadeTo(200, 1).delay(2000).fadeOut(1000, 0)
      )
      e.preventDefault()
