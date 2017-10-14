define ['require'], ->
	require ['app'], ->
		# Initialize position
		$('.trip-info').each ->
			$(this).css('bottom', -$(this).find('.description').outerHeight())
		
		# Events
		$('.trip-item').mouseenter ->
			$(this).find('.trip-info').css('bottom', 0)
		
		$('.trip-item').mouseleave ->
			$(this).find('.trip-info').css('bottom', -$(this).find('.description').outerHeight())
