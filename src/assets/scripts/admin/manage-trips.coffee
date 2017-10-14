define ['require'], ->
	require ['app'], ->
		require ['semantic'], ->
			$('.delete-trip').click ->
				id = $(this).attr('id')
				try
					id = id.substring(7, id.length)
					console.log id
					$('.ui.basic.modal.confirm_delete').modal(
						onApprove: ->
							$.ajax
								method: 'POST',
								url: '/admin/trip/delete',
								data: { id: id },
								success: (result) ->
									console.log result
									if result.success
										$('#trip_' + id).hide()
								error : (xhr) ->
									console.log xhr.status + " " + xhr.statusText
					)
					.modal('show')
				catch err
					console.log err.message
