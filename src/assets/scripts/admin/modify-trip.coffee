define ['require'], ->
	require ['app'], ->
		require ['jquery.validate'], ->
			$('#form-modify').validate
				lang: 'de',
				submitHandler: (form, event) ->
					event.preventDefault()
					data = new FormData()
					form_data = $('#form-modify').serializeArray()
					$.each(form_data, (index, field) ->
						data.append(field.name, field.value)
					)
					# Add Description
					data.append('description', $('#description .ql-editor').html())
					data.append('services', $('#services .ql-editor').html())
					$.each($("input[type='file']")[0].files, (index, file) ->
						data.append('file', file)
					)

					data.append('sort', $('.images-list > .image').map(() -> return this.id; ).get())

					$.ajax
						type: 'POST'
						url: '/admin/trip/save'
						cache: false
						contentType: false
						processData: false
						data : data
						success: (result) ->
							if result.success
								window.location.href = "/admin/trip/manage"
							else
								$('.ui.error.message .message').html(result.message)
								$('.ui.error.message').show()
						error: (err) ->
							$('.ui.error.message .message').html(result.message)
							$('.ui.error.message').show()
	
		require ['jquery-ui'], ->
			# Datepicker
			$( "input[id='date_begin_string']" ).datepicker
				changeMonth: true,
				changeYear: true,
				altFormat: "yy-mm-dd",
				dateFormat:"DD, d. MM, yy",
				altField: "#date_begin"
				
			$( "input[id='date_end_string']" ).datepicker
				changeMonth: true,
				changeYear: true,
				altFormat: "yy-mm-dd",
				dateFormat:"DD, d. MM, yy",
				altField: "#date_end"
			
			$.datepicker.setDefaults($.datepicker.regional["de"])
		
		# Quill
		require ['quill'], (Quill) ->
			description = new Quill '#description', theme: 'snow'
			services = new Quill '#services',	theme: 'snow'
			
			# Description
			$.ajax
				type: 'post'
				url: '/admin/trip/getDescription'
				data:
					tripId: $('#tripId').val()
				success: (data) ->
					if data.success
						$('#description .ql-editor').html(data.content.description)
			
			# Services
			$.ajax
				type: 'post'
				url: '/admin/trip/getServices'
				data:
					tripId: $('#tripId').val()
				success: (data) ->
					if data.success
						$('#services .ql-editor').html(data.content.services)

		require ['semantic'], ->
			$.ajax
				type: 'post'
				url: '/admin/trip/getTags'
				data:
					tripId: $('#tripId').val()
				success: (data) ->
					if data.success
						$('.ui.dropdown').dropdown('set selected', data.content.tags)
						$('.ui.dropdown').dropdown('refresh')
		
		# Multifile upload
		require ['jQuery.MultiFile'], ->
			# this is your selector
			$('input.file').MultiFile
				max: 10
				accept: 'jpg|png|gif'

		# IMAGE ACTIONS
		
		# Move image
		$('.move-up').click ->
			move($(this).data('id'), true)
		$('.move-down').click ->
			move($(this).data('id'), false)

		move = (id, up) ->
			list = $('.images-list .image')
			el = document.getElementById(id)
			currentIndex = list.index(el)

			if up && currentIndex > 0
				$(el).insertBefore(list.get(currentIndex - 1))
			else if !up && currentIndex < list.length - 1
				$(list.get(currentIndex + 1)).insertBefore(list.get(currentIndex))
			else
				console.log "Element cannot be moved in this direction."

		# Delete Image
		$('.deleteImage').click ->
			id = $('#tripId').val()
			filename = $(this).attr('id')
			try
				filename = filename.substring(7, filename.length)
			catch err
				return console.log(err)

			$('.ui.basic.modal.confirm_delete').modal(
				onApprove : () ->
					$.ajax
						method: 'POST',
						url: '/admin/trip/deleteImage',
						data: { id: id, filename: filename },
						success : (result) ->
							if result.success
								$('.ui.error.message').hide()
								$('div[id="' + filename + '"]').hide()
							else
								$('.ui.error.message .message').html(result.message)
								$('.ui.error.message').show()
						error : (err) ->
							$('.ui.error.message .message').html(err)
							$('.ui.error.message').show()
			)
			.modal('show')
			
