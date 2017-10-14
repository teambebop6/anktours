define ['require'], ->
	require ['app'], ->
		
		require ['jquery.validate', 'jquery.validate.de'], () ->
			setMessage = (result) ->
				msg = $('.ui.message.flash')
				success = result.status == 200
				message = result.message
				msg.find('.header').html(if success then "Vielen Dank!" else "Fehler!")
				msg.find('.content').html(if message then message)
				msg.addClass(if success then "success" else "error")
				msg.show()
			
			# Swiss phone number
			jQuery.validator.addMethod("phoneCH",
				(phone_number, element) ->
					phone_number = phone_number.replace(/\s+/g, "")
					return this.optional(element) || phone_number.length > 9 &&
						phone_number.match(/^(?:(?:|0{1,2}|\+{0,2})41(?:|\(0\))|0)([1-9]\d)(\d{3})(\d{2})(\d{2})$/)
			, "Bitte geben Sie eine gültige Telefonnummer ein!")

			$('form#contact').submit((event) ->
				event.preventDefault()
			).validate(
				rules: {
					'contact[phone]': {
						phoneCH: true,
						required: true
					},
					'contact[first_name]': {
							required: true
					},
					'contact[last_name]': {
						required: true
					},
					'contact[email]': {
						required: true
						email: true
					}
				}
				submitHandler: (form) ->
					$(form).find(':submit').addClass("loading")
					$(form).find(':submit').addClass("disabled")
					$.ajax(
						type: "POST"
						url: "/reservation"
						data: $(form).serialize()
						success: (result) ->
							setMessage(result)
							if result.status == 200
								$('.finish-reservation').hide()

							else
								$(form).find(':submit').removeClass("loading")
								$(form).find(':submit').removeClass("disabled")
						error: (err) ->
							console.log err
							setMessage(err.message, "error")
							$(form).find(':submit').removeClass("loading")
							$(form).find(':submit').removeClass("disabled")
					)
				)


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

