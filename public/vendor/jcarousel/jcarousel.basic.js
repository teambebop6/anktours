(function($) {
	$(function() {
		$('.jcarousel').jcarousel({
			wrap: 'circular',
			animation: 2500,
			initCallback: function(carousel) {
				$('.jcarousel-wrapper .next').click(function() {
					// turn off autoscroll
					$('.jcarousel').jcarouselAutoscroll('stop');


					//$('.jcarousel').jcarousel({
					//	animation: {
					//		duration: 500,
					//		complete: function() {
					//		
					//			$('.jcarousel').jcarousel({
					//				animation: {
					//					duration: 2500
					//				}
					//			});
					//			
					//			$(this).jcarouselAutoscroll('start');
					//		}
					//	}
					//});

					$('.jcarousel').jcarousel('scroll', '+=1');

				});
			}
		})
	});
})(jQuery);
