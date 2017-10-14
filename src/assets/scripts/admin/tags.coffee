define ['require'], ->
	require ['app'], ->
		$('.delete').click ->
			value = $(this).attr('id')
			console.log value
			$.ajax(
				method: "post",
				url: '/admin/tags/delete',
				data:
					value: value
				,
				success: (data) ->
					if data.status == 200
						$('#' + value).first().parent('.item').hide()
			)
