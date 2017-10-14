define ->
	require.config
		baseUrl: "/assets"
		waitSeconds: 200
		jsx:
			fileExtension: '.jsx'
		paths:
			'jquery-ui/ui/widget': 'js/vendor/jquery.ui.widget',
			'slick': 'vendor/slick/slick.min'
			'jquery': 'vendor/jquery-1.10.2.min'
			"react": "https://unpkg.com/react@15/dist/react"
			"React": "https://unpkg.com/react@15/dist/react"
			"react-dom": "https://unpkg.com/react-dom@15/dist/react-dom"
			"ReactDOM": "https://unpkg.com/react-dom@15/dist/react-dom"
			"react-tags": "vendor/ReactTags.min"
			"ReactDnD": "vendor/react-dnd/ReactDnD.min"
			"text": "vendor/text"
			'semantic': 'vendor/semantic/semantic.min'
			'main': 'js/main'
			'app': 'js/app'
			'datepicker_regional_de': 'vendor/jquery-ui/datepicker_regional_de'
			'jQuery.MultiFile': 'vendor/jQuery.MultiFile.min'
			'jquery.jcarousel': 'vendor/jcarousel/jquery.jcarousel.min'
			'jcarousel.basic': 'vendor/jcarousel/jcarousel.basic'
			'jquery-ui': 'vendor/jquery-ui/jquery-ui'
			'jquery_cycle': 'vendor/js/jquery.cycle2.min'
			'jquery_cycle_carousel': 'vendor/js/jquery.cycle2.carousel.min'
			'jquery_cycle_flip': 'vendor/js/jquery.cycle2.flip.min'
			'jquery.validate': 'vendor/jquery-validation/jquery.validate.min'
			'jquery-validate.addmeth': 'vendor/jquery-validation/additional-methods'
			'jquery.validate.de': 'vendor/jquery-validation/jquery.validate.de'
			'quill': '//cdn.quilljs.com/1.0.0/quill'
		shim:
			'semantic' : ['jquery']
			'globals': ['jquery']
			'jquery_cycle_carousel': ['jquery_cycle']
			'jquery_cycle_flip': ['jquery_cycle']
			'jquery.validate': ['jquery']
			'jquery.validate.de': ['jquery.validate']
			'jcarousel.basic' : ['jquery.jcarousel']
			'jquery-ui/ui/widget': ['jquery']
			'datepicker_regional_de': ['jquery-ui']
			'jquery-validate.addmeth': ['jquery.validate']
