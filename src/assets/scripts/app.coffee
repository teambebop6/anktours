define ['require', 'jquery'], (require, $) ->
	# Initialized application
	require ['semantic'], ->
		$('.broschure').mouseenter ->
			$(this).transition('tada')
		
		$('.ui.dropdown').dropdown(
			forceSelection: false # Semantic issue 4506
		)
