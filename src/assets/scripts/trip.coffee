define ['require'], ->
	require ['app'], ->
	
		require ['slick'], ->
			$('.slick').slick(
				infinite: true
				speed: 3000
				slidesToShow: 3
				slidesToScroll: 1
				centerMode: true
				variableWidth: true
				autoplay: true
				autoplaySpeed: 2000
				prevArrow: ''
				nextArrow: ''
				waitForAnimate: false
			)

			$('.slick-prev').click ->
				$('.slick').slick("slickPrev")
			$('.slick-next').click ->
				$('.slick').slick("slickNext")
