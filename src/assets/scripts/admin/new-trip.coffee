define ['require'], ->
	require ['app'], ->
		require ['jquery.validate'], ->
			$('#form-new').validate
				ignore: '.ql-editor input'
				submitHandler: (form, event) ->
					event.preventDefault()
					data = new FormData()
					form_data = $('#form-new').serializeArray()
					
					console.log form_data

					$.each(form_data, (index, field) ->
						data.append(field.name, field.value)
					)
					# Add rich text description
					data.append('description', $('#description .ql-editor').html())
					data.append('services', $('#services .ql-editor').html())

					$.each($("input[type='file']")[0].files, (index, file) ->
						data.append('file', file)
					)
					$('button[type="submit"]').addClass('loading')
					$('button[type="submit"]').addClass('disabled')
					
					$.ajax
						type: 'POST'
						url: '/admin/trip/new'
						cache: false
						contentType: false
						processData: false
						data : data
						success: (result) ->
							if result.success
								window.location.href = "/admin/trip/manage"
							else
								$('.ui.error.message').show()
								$('.ui.error.message .message').html(result.message)
								$('button[type="submit"]').removeClass('loading')
								$('button[type="submit"]').removeClass('disabled')
						error: (err) ->
							$('.ui.error.message').show()
							$('.ui.error.message .message').html(err)
							$('button[type="submit"]').removeClass('loading')
							$('button[type="submit"]').removeClass('disabled')
				
		require ['quill'], (Quill) ->
			# Initialize quill
			description = new Quill '#description', theme: 'snow'
			services = new Quill '#services', theme: 'snow'

		require ['jquery-ui'], ->
			# Datepicker
			$( "input[id='date_begin_string']").datepicker
				changeMonth: true
				changeYear: true
				altFormat: "yy-mm-dd"
				dateFormat:"DD, d. MM, yy"
				altField: "#date_begin"
				onSelect: (dateText) ->
					$('#form-new').valid()

			$( "input[id='date_end_string']").datepicker
				changeMonth: true,
				changeYear: true,
				altFormat: "yy-mm-dd",
				dateFormat:"DD, d. MM, yy",
				altField: "#date_end",
				onSelect: (dateText) ->
					$('#form-new').valid()

			$.datepicker.setDefaults($.datepicker.regional["de"])
		
		require ['semantic'], ->
			$('.ui.dropdown').dropdown()


		# Multifile upload
		require ['jQuery.MultiFile'], ->
			$('input.file').MultiFile
				max: 10,
				accept: 'jpg|png|gif'
