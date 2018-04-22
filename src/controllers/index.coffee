express = require('express')
router = express.Router()
easyPbkdf2 = require('easy-pbkdf2')()

helpers = require('../../lib/helpers')

# Load models
Trip = require('../models/trip')
News = require('../models/news')
Tags = require('../models/tag')
User = require('../models/user')
Galery = require('../models/galery')
galeries = []

passport = require('passport')
validator = require('validator')

# Passport.js Local Strategy
LocalStrategy = require('passport-local').Strategy
passport.use new LocalStrategy (username, password, done) ->
  User.findOne {username: username}, (err, user) ->
    if err
      return done(err)
    if !user
      return done(null, false, message: 'Incorrect username.')

    easyPbkdf2.secureHash password, user.salt, (err, hash, originalSalt) ->
      if err
        return done(err)

      if hash == user.password
        return done(null, user)

      done(null, false, message: 'Incorrect password.')
    return
  return

router.all '/*', (req, res, next) ->
  req.app.locals.layout = 'main'

  Galery.find {}, (err, gals) ->
    galeries = gals

    next()

sendMail = (transporter, mailOptions, cb) ->
  console.log "Sending email..."
  transporter.sendMail(mailOptions, (err, info) ->
    if err then return cb(err)
    console.log "Sent mail!"
    cb(null)
  )

router.post '/reservation', (req, res, next) ->
  if req.body.honeypot
    return res.json({status: 400, message: "Ein Fehler ist aufgetreten."})

  numberOfTravellers = req.body['number_of_travellers']

  contact = req.body.contact
  if !contact.last_name
    return res.json({status: 400, message: "Bitte geben Sie einen Namen ein."})
  if !contact.first_name
    return res.json({status: 400, message: "Bitte geben Sie einen Vornamen ein."})
  if !contact.phone
    return res.json({
      status: 400,
      message: "Damit wir Sie kontaktieren können, geben Sie bitte eine Telefonnummer ein."
    })
  if !contact.email
    return res.json({status: 400, message: "Bitte geben Sie auch eine Email-Adresse ein."})

  Trip.findOne({_id: req.body.trip_id}, (err, trip) ->
    if(err) then return res.json({status: 400, message: err.message})
    if(!trip) then return res.json(status: 400, message: "Diese Reise scheint nicht zu existieren.")

    comments = req.body.comments

    tags = {
      pickup: req.body.pickup == 'on'
      disabilities: req.body.disabilities == 'on'
      vegi: req.body.vegetarian == 'on'
    }
    name = contact.first_name + " " + contact.last_name

    date = helpers.formatDate(trip.date_begin)

    html = "<p>Neue Reservation von " + name + " für die Reise " + trip.title + " am " + date + " eingetroffen.</p>" +
      "<p>Anzahl Reisende: " + numberOfTravellers + "</p>" +
      "<p>Telefon: " + contact.phone + "</p>" +
      "<p>Email: " + contact.email + "</p>" +
      "<p>Kommentar:</p> <div>" + comments + "</div>"

    text = "Neue Reservation von " + name + " für die Reise " + trip.title + " am " + date + " eingetroffen. \r\n " +
      "\r\n" +
      "Telefon: " + contact.phone + "\r\n" +
      "\r\n" +
      "Email: " + contact.email + "\r\n" +
      "\r\n" +
      "Kommentare: " + comments + "\r\n" +
      "\r\n"

    if tags.vegi || tags.disabilities || tags.pickup
      html = html.concat "<p>Tags: "
      text = text.concat "\r\n Tags: "

      if tags.vegi
        html = html.concat "Vegi, "
        text = text.concat "Vegi, "
      if tags.disabilities
        html = html.concat "Reisende mit Behinderung, "
        text = text.concat "Reisende mit Behinderung, "
      if tags.pickup
        html = html.concat "Abholung zu Hause"
        text = text.concat "Abholung zu Hause"

      html = html.concat "</p>"

    mailOptions =
      from: '"A.N.K. - Tours" <no-reply@ank-tours.ch>',
      replyTo: name + "<" + contact.email + ">",
      to: req.config.MAILTO || "Florian Rudin <flaudre@gmail.com>",
      subject: "Reservationsanfrage: " + trip.title,
      html: html,
      text: text

    sendMail(req.transporter, mailOptions, (err) ->
      if(err) then return err

      return res.json({
        status: 200,
        message: "Ihre Reservation ist nun abgeschlossen und wird von uns bearbeitet. Wir melden uns in den nächsten Tagen telefonisch bei Ihnen!"
      })
    )
  )


router.get '/galery/:id([a-zA-Z0-9]+)', (req, res, next) ->
  Galery.findSorted {_id: req.params.id}, (err, galery) ->
    if err then return next(err)
    if !galery then return next({status: 400, message: "Galery not found!"})

    res.render 'galery',
      title: 'Galerie: ' + galery.title
      galery: galery
      page_script: 'js/galery'
      galeries: galeries

router.get '/impressum', (req, res, next) ->
  res.render 'impressum',
    title: 'Impressum'
    galeries: galeries

router.get '/agb', (req, res, next) ->
  return res.render 'agb',
    title: 'Allgemeine Geschäftsbedingungen'
    galeries: galeries

router.get '/cars', (req, res, next) ->
  cars = [
    {
      name: 'Setra 516 HDH'
      color: ''
      images: ['hdh_1.png', 'hdh_2.png', 'hdh_3.png', 'hdh_4.png', 'hdh_5.png', 'hdh_6.png', 'hdh_7.png', 'hdh_8.png',
        'hdh_9.png']
      filter: true
      techs: [
        {title: 'Länge', icon: 'icon-ruler', description: '13.30m'}
        {title: 'Motor', icon: 'icon-gauge', description: 'Euro 6'}
        {title: 'Partikelfilter', icon: 'ui icon checkmark', description: 'Für Mensch und Umwelt.'}
        {title: 'ABS', icon: 'ui checkmark icon', description: 'Antiblockiersystem'}
        {title: 'EBS', icon: 'ui checkmark icon', description: 'Elektronisches Bremssystem'}
        {title: 'ASR', icon: 'ui checkmark icon', description: 'Traktionskontrolle'}
      ]
      features: [
        {title: 'Sitzplätze', icon: 'ui soccer icon', description: '50 Sitzplätze'}
        {title: 'TV Empfang', icon: 'ui soccer icon'}
        {title: 'Bordküche', icon: 'ui food icon'}
        {title: 'Kaffeemaschine', icon: 'ui coffee icon', description: 'Nespresso'}
        {title: 'Kühlschränke', icon: 'icon-snow', description: 'Insgesamt: 2'}
        {title: 'Steckdose', icon: 'ui plug icon', description: '230V'}
        {title: 'Navigationssystem', icon: 'icon-location'}
        {title: 'Sichtkameras', icon: 'icon-videocam', description: 'Fahrersichtkamera und Rückfahrkamera'}
        {title: 'TopSky Glasdach', icon: 'icon-sun'}
        {title: 'LCD Bildschirme', icon: 'icon-monitor', description: 'Insgesamt 3 Bildschirme'}
        {title: 'Komfortsitze', icon: 'icon-star', description: 'Sitze der Voyage-Supreme-Generation'}
        {title: 'Parkettboden', icon: 'icon-star'}
        {title: 'WC', icon: 'icon-toilet'}
        {title: 'Waschraum', icon: 'icon-water'}
        {title: 'Video und CD-Player', icon: 'icon-play'}
      ]
    },
    {
      name: 'Setra TopClass 500'
      color: 'blue'
      avatar: 'setra_avatar.png'
      images: ['setra_6.jpg', 'setra_7.jpg', 'setra_3.jpg', 'setra_4.jpg', 'setra_5.jpg', 'setra_1.jpg', 'setra_2.jpg']
      filter: true
      techs: [
        {title: 'Länge', icon: 'icon-ruler', description: '13.30m'}
        {title: 'Motor', icon: 'icon-gauge', description: 'Euro 6'}
        {title: 'Partikelfilter', icon: 'ui checkmark icon', description: 'Für Mensch und Umwelt.'}
        {title: 'ABS', icon: 'ui checkmark icon', description: 'Antiblockiersystem'}
        {title: 'EBS', icon: 'ui checkmark icon', description: 'Elektronisches Bremssystem'}
        {title: 'ASR', icon: 'ui checkmark icon', description: 'Traktionskontrolle'}
      ]
      features: [
        {title: 'Sitzplätze', icon: 'ui soccer icon', description: '46 (Normalbestuhlung 40 + Clubecke 6)'}
        {title: 'TV Empfang', icon: 'ui soccer icon'}
        {title: 'Bordküche', icon: 'ui food icon'}
        {title: 'Kaffeemaschine', icon: 'ui coffee icon', description: 'Nespresso'}
        {title: 'Kühlschränke', icon: 'icon-snow', description: 'Insgesamt: 2'}
        {title: 'Steckdose', icon: 'ui plug icon', description: '230V'}
        {title: 'Navigationssystem', icon: 'icon-location'}
        {title: 'Sichtkameras', icon: 'icon-videocam', description: 'Fahrersichtkamera und Rückfahrkamera'}
        {title: 'TopSky Glasdach', icon: 'icon-sun'}
        {title: 'LCD Bildschirme', icon: 'icon-monitor', description: 'Insgesamt 3 Bildschirme'}
        {title: 'Komfortsitze', icon: 'icon-star', description: 'Sitze der Voyage-Supreme-Generation'}
        {title: 'Parkettboden', icon: 'icon-star'}
        {title: 'WC', icon: 'icon-toilet'}
        {title: 'Waschraum', icon: 'icon-water'}
        {title: 'Video und CD-Player', icon: 'icon-play'}
      ]
    },
    {
      name: 'MAN Lion\'s Coach'
      color: 'red'
      avatar: 'lion_avatar.png'
      images: [
        'lion_0.jpg', 'lion_1.jpg', 'lion_2.jpg', 'lion_3.jpg', 'lion_4.jpg', 'lion_5.jpg'
      ]
      techs: [
        {title: 'Länge', icon: 'icon-ruler', description: '13.26 m'}
        {title: 'Motor', icon: 'icon-gauge', description: 'Euro 4'}
        {title: 'Partikelfilter', icon: 'ui checkmark icon', description: 'Für Mensch und Umwelt.'}
        {title: 'ABS', icon: 'ui checkmark icon', description: 'Antiblockiersystem'}
        {title: 'EBS', icon: 'ui checkmark icon', description: 'Elektronisches Bremssystem'}
        {title: 'ASR', icon: 'ui checkmark icon', description: 'Traktionskontrolle'}
      ]
      features: [
        {
          title: 'Sitzplätze',
          icon: 'ui soccer icon',
          description: '52 Sitzplätze (umbaubar zu 48 Sitzplätzen mit zwei Clubtischen)'
        }
        {title: 'Bordküche', icon: 'ui food icon'}
        {title: 'Kaffeemaschine', icon: 'ui coffee icon', description: 'Nespresso'}
        {title: 'LCD', icon: 'icon-monitor', description: 'Insgesamt 2 Bildschirme'}
        {title: 'Schlafsessel', icon: 'icon-moon-inv'}
        {title: 'Fussstützen', icon: 'ui checkmark icon'}
        {title: 'Klapptische', icon: 'ui checkmark icon'}
        {title: 'Leseleuchten', icon: 'icon-bulb'}
        {title: 'Klimaanlage', icon: 'icon-air'}
        {title: 'Gepäckablage', icon: 'icon-suitcase'}
        {title: 'WC', icon: 'icon-toilet'}
        {title: 'Waschraum', icon: 'icon-water'}
        {title: 'Video und CD-Player', icon: 'icon-play'}
        {title: 'Mikrofon', icon: 'icon-mic'}
        {title: 'Fahrerschlafkabine', icon: 'icon-moon-inv'}
      ]
    },
    {
      name: 'Viano'
      capacity: '7 (inkl. Chauffeur)'
      price: 'CHF 270.-/Tag'
      techs: [
        {title: 'Leistung', icon: 'ui lightning icon', description: '224 PS'}
      ]
      features: [
        {title: 'Ledersitze', icon: 'ui checkmark icon'}
        {title: 'Licht-Regensensor', icon: 'ui checkmark icon'}
        {title: 'Klimaanlage', icon: 'icon-air'}
        {title: 'Parktronik-System', icon: 'ui checkmark icon'}
        {title: 'Radio/CD', iconi: 'ui music icon'}
        {title: 'Tempomat', icon: 'ui checkmark icon'}
        {title: 'Anhängerkupplung', icon: 'ui checkmark icon'}
      ]
      images: [
        'viano_1.jpg'
        'viano_2.jpg'
        'viano_3.jpg'
        'viano_4.jpg'
        'viano_5.jpg'
        'viano_6.jpg'
        'viano_7.jpg'
      ]
    },
    {
      name: 'Kleinbus'
      price: 'CHF 270.-/Tag'
      description: "Der Kleinbus kann gemietet und selbst gefahren werden, sofern der Fahrer im Besitz eines Führerausweises Kat. B ist und die Prüfung vor dem 1. April 2003 bestanden hat."
      capacity: '14 (inkl. Chauffeur)'
      techs: [
        {title: 'Leistung', icon: 'ui lightning icon', description: '163 PS'}
      ]
      features: [
        {title: 'Sitzplätze mit Teillederkombination', icon: 'ui checkmark icon'}
        {title: 'Licht-Regensensor', icon: 'ui checkmark icon'}
        {title: 'Hochdach', icon: 'ui checkmark icon'}
        {title: 'Klimaanlage', icon: 'icon-air'}
        {title: 'Parktronik-System', icon: 'ui checkmark icon'}
        {title: 'Radio/CD', iconi: 'ui music icon'}
        {title: 'Tempomat', icon: 'ui checkmark icon'}
        {title: 'Anhängerkupplung', icon: 'ui checkmark icon'}
      ]
      images: ['kleinbus_1.jpg', 'kleinbus_2.jpg', 'kleinbus_3.jpg', 'kleinbus_4.jpg', 'kleinbus_5.jpg',
        'kleinbus_6.jpg', 'kleinbus_7.jpg'
      ]
    },
    {
      name: 'Postauto'
      images: [
        'postauto.jpg', 'postauto.jpg', 'postauto.jpg', 'postauto.jpg'
      ]
    },
    {
      name: 'Anhänger'
      images: [
        'anhaenger_3.jpg', 'anhaenger_4.jpg', 'anhaenger_5.jpg'
      ]
    },
    {
      name: 'Veloanhänger'
      description: "Wir transportieren bis zu 34 Fahrräder oder 6 Motorräder sicher und zuverlässig ans Reiseziel."
      images: [
        'velo_3.jpg', 'velo_4.jpg', 'velo_5.jpg', 'velo_6.jpg', 'velo_7.jpg'
      ]
    }
  ]

  return res.render 'cars',
    page_script: 'js/cars'
    page_styles: []
    title: 'Die Fahrzeugflotte'
    galeries: galeries
    cars: cars

router.get '/about', (req, res) ->
  return res.render 'about',
    title: 'Über uns'
    page_script: 'js/about'
    galeries: galeries


router.get '/reservation', (req, res, next) ->
  res.render 'message',
    flash: req.flash()

router.get '/reservation/:id', (req, res, next) ->
  Trip.findOne {'_id': req.params.id}, (err, trip) ->
    if err then return next(err)
    if !trip
      res.redirect '/'
      return
    return res.render 'reservation',
      trip: trip
      _: helpers
      title: 'Reservation: ' + trip.title
      page_styles: ['css/jcarousel.basic']
      page_script: 'js/reservation'
      galeries: galeries

router.get '/trips', (req, res) ->
  query_tags = (new String(req.query.tag)).split(',')
  query = {tags: query_tags}
  if query_tags[0] == "all"
    query = {}
  now = new Date()

  Trip.find({date_end: {$gt: now}}).sort(date_begin: 'asc').exec (err, trips) ->
    if err then return err

    Tags.find {}, (err, db_tags) ->
      selected_tags = []
      if err then console.log err
      else
        tag_string = ""
        # get tags
        query_tags.forEach (tag) ->
          match = (db_tags.filter (t) -> return t.value == tag)[0]
          if match
            selected_tags.push(match)
            tag_string += match.name + ', '
          else
            selected_tags.push(tag)
            tag_string += tag + ', '

        tag_string = tag_string.slice(0, -2)

      res.render 'multi_day_trips',
        trips: db_trips
        title: 'Aktuelle Reisen (Filter: ' + tag_string + ')'
        _: helpers
        page_script: 'js/home'
        page_styles: ['css/trip']
        galeries: galeries

router.get '/multi-day-trips', (req, res) ->
  multi_day_trips = []
  now = new Date()
  Trip.find({date_end: {$gt: now}}).sort(date_begin: 'asc').exec (err, trips) ->
    if err then return err

    trips.forEach (trip) ->
      if helpers.isMultiDay(trip)
        multi_day_trips.push trip

    res.render 'multi_day_trips',
      trips: multi_day_trips
      title: 'Aktuelle Ferienreisen'
      _: helpers
      page_script: 'js/home'
      page_styles: ['css/trip']
      galeries: galeries

router.get '/day-trips', (req, res) ->
  day_trips = []
  now = new Date()
  Trip.find({date_end: {$gt: now}}).sort(date_begin: 'asc').exec (err, trips) ->
    if err
      console.log err
      return
    trips.forEach (trip) ->
      if !helpers.isMultiDay(trip)
        day_trips.push trip
      return
    res.render 'day_trips',
      trips: day_trips
      title: 'Aktuelle Tagesfahrten'
      _: helpers
      page_script: 'js/home'
      page_styles: ['css/trip']
      galeries: galeries
    return
  return

router.get '/trip/:id', (req, res, next) ->
  Trip.findSorted {'_id': req.params.id}, (err, trip) ->
    if err then return next(err)

    Tags.find {}, (err, db_tags) ->
      trip_tags = []

      if err then console.log err
      else
# get tags
        trip.tags.forEach (tag) ->
          tag_to_add = (db_tags.filter (t) -> return t.value == tag)[0]

          if !tag_to_add
            tag_to_add =
              name: tag
              vale: tag

          if tag_to_add
            trip_tags.push(tag_to_add)

      res.render 'trip',
        title: 'Reise'
        trip: trip
        _: helpers
        tags: trip_tags
        page_styles: []
        page_script: 'js/trip'
        galeries: galeries

router.get '/login', (req, res) ->
  res.render 'login',
    title: "Login"
    page_styles: ['admin']
    message: req.flash('error')
  return

router.post '/login', passport.authenticate('local',
  successRedirect: '/admin'
  failureRedirect: '/login'
  failureFlash: true
)

router.get '/contact', (req, res) ->
  return res.render 'contact',
    title: 'Kontakt'
    page_script: ['js/contact']
    page_styles: []
    errorMessage: req.flash('errorMessage')
    successMessage: req.flash('successMessage')
    galeries: galeries

router.post '/contact', (req, res, next) ->
  honeypot = req.body.first_name

  if honeypot
    return res.json({status: 400, message: "Es ist ein Fehler aufgetreten."})

  # Check for inputs
  vorname = req.body.vorname
  name = req.body.name
  email = req.body.email
  message = req.body.text

  if !email or !validator.isEmail(email)
    return res.json({status: 400, message: "Bitte geben Sie eine gültige Email-Adresse ein."})

  if !vorname or !name or validator.isEmpty(vorname) or validator.isEmpty(name)
    return res.json({status: 400, message: "Bitte geben sie einen gültigen Namen und Vornamen an."})

  if !message || validator.isEmpty(message)
    return res.json({status: 400, message: "Bitte geben sie eine Nachricht an."})


  # Mail content
  full_name = vorname + " " + name
  html = "<p>Grüezi!</p>" +
    "<p>" + full_name + " (" + email + ") hat Ihnen eine Nachricht auf ank-tours.ch hinterlassen.</p>" +
    "<p><strong>Nachricht:</strong></p><p>" + message + "</p>"

  text = "Grüezi! \n\r" +
    vorname + " " + name +
    " (" + email + ") hat Ihnen eine Nachricht auf ank-tours.ch hinterlassen. \n\r" +
    "Nachricht: \n\r " + message

  replyTo = vorname + ' ' + name + ' <' + email + '>'

  mailOptions =
    from: '"A.N.K. - Tours" <no-reply@ank-tours.ch>',
    replyTo: replyTo,
    to: req.config.MAILTO || "Florian Rudin <flaudre@gmail.com>",
    subject: "Neue Nachricht auf ank-tours.ch",
    html: html,
    text: text

  sendMail(req.transporter, mailOptions, (err) ->
    if(err) then return res.json({status: 400, message: err.message})

    return res.json({status: 200, message: "Das Formular wurde erfolgreich gesendet."})
  )

router.get '/', (req, res, next) ->
  now = new Date()

  tripPromise = new Promise((resolve, reject) ->
    Trip.find({date_end: {$gt: now}}).sort(date_begin: 'asc').limit(3).exec (err, trips) ->
      if err
        reject err
      else
        resolve trips
  )

  newsPromise = new Promise((resolve, reject) ->
    news = [{title: 'news title'}]

    cond = {
      active: true,
    }
    News.find(cond).sort(date: 'desc').limit(3).exec (err, news) ->
      if err
        reject err
      else
        resolve news
  )

  Promise.all([tripPromise, newsPromise]).then((results) ->
    console.log(results)
    res.render 'home',
      trips: results[0]
      newses: results[1]
      title: 'Aktuelle Reisen'
      _: helpers
      page_script: 'js/home'
      galeries: galeries
      active:
        home: true
    return
  ).catch((err) ->
    return next(err)
  )


module.exports = router
