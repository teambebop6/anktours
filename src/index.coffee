express					= require 'express'
path						= require 'path'
favicon					= require 'serve-favicon'
cookieParser		= require 'cookie-parser'
bodyParser			= require 'body-parser'
exphbs					= require 'express-handlebars'
mongoose				= require 'mongoose'
passport				= require 'passport'
flash						= require 'connect-flash'
nodemailer = require('nodemailer')

require('dotenv').config()

User						= require './models/user'
app = express()

session					= require 'express-session'
RedisStore			= require('connect-redis')(session)

# Config and environment
config = require('./secret/config')
env = process.env.NODE_ENV or "development"
config.setEnvironment env
app.set('config', config)

transporter = nodemailer.createTransport(config.SMTP_TRANSPORT)

# Pass config to request
app.use (req, res, next) ->
	req.config = config
	req.transporter = transporter
	next()

app.port = process.env.PORT or config.APP_PORT or 3000
app.host = process.env.HOST or '127.0.0.1'

# Set view engine
app.set 'view engine', 'pug'

# Load Database
db = require('./db')
db.connect(config)

# Uncomment after placing your favicon in /public
#app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: true)
app.use cookieParser('brewdog WUFF!')
expires_date = new Date()
store = new RedisStore(
	host: config.REDIS_HOST
	port: config.REDIS_PORT
)
store.on 'connect', ->
	console.log "Connected to redis."
store.on 'disconnect', ->
	console.log "Redis is disconnected."

app.use session(
	name: 'anktours'
	store: store
	secret: 'brewdog WUFF!'
	resave: true
	saveUninitialized: true
	cookie:
		maxAge:7*24*60*60*1000 # ms
)

# Passport.js 
app.use passport.initialize()
app.use passport.session()
passport.serializeUser (user, done) ->
	done null, user._id
passport.deserializeUser (id, done) ->
	User.findById id, (err, user) ->
		done(err, user)

app.use flash()

# Upload
upload = require('./config/upload')
upload.configure(app)

# Initialize router
app.use '/', require('./routes')


# Error handler
app.use (err, req, res, next) ->
	console.log "Error!"
	console.log err
	res.status(err.status || 500)
	res.render 'errors/error',
		title: 'Error'
		message: err.message
		error: if app.get('env') != "production" then err else {}

module.exports = app
