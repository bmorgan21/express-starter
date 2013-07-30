express = require('express')
flash = require('connect-flash')
path = require('path')
MongoStore = require('connect-mongo')(express)

passport = require('passport')
GoogleStrategy = require('passport-google').Strategy
models = require('../models')

passport.serializeUser((user, done) ->
    done(null, user.id)
)

passport.deserializeUser((id, done) ->
    models.User.findById(id, done)
)

exports.configure = (app, skin) ->
    app.set('port', process.env.PORT || 3000)
    hostname = 'localhost:' + app.get('port')

    # our custom "verbose errors" setting
    # which we can use in the templates
    # via settings['verbose errors']
    app.enable('verbose errors')

    # disable them in production
    # use $ NODE_ENV=production node examples/error-pages
    if ('production' == app.settings.env)
        app.disable('verbose errors')
        hostname = 'stash.openmile.com'

    app.use(express.responseTime())
    app.use(express.favicon(path.join(skin, 'public/img/favicon.ico')))
    app.use(express.logger('dev'))
    app.use(express.cookieParser('echo echo echo can you hear me?'))
    app.use(express.session({ secret: 'keyboard cat', cookie: { maxAge: 600000 }, store: new MongoStore({db:'stash'})}))

    app.use(passport.initialize())
    app.use(passport.session())
    passport.use(new GoogleStrategy({
        returnURL: "http://#{hostname}/auth/callback/",
        realm: "http://#{hostname}/"
      },
      (identifier, profile, done) ->
        models.User.findOneAndUpdate({open_id: identifier},
            {open_id: identifier,
            first_name: profile.name.givenName,
            last_name: profile.name.familyName,
            email: profile.emails[0].value
            },
            {upsert: true}, done)
    ))

    app.use(express.bodyParser())
    app.use(express.methodOverride())
    app.use(flash())
    app.use((req, res, next) ->
        res.locals.flash = () -> return req.flash() || {}
        res.locals.helpers = require('./helpers')
        res.locals.user = req.user

        req.coords = null
        if req.cookies.coords
            try
                req.coords = JSON.parse(req.cookies.coords)
            catch
                pass

        next()
    )
    app.use((req, res, next) -> #monkey patch express to properly handle json flashes and redirects
        shadow = {json: res.json, redirect: res.redirect}

        res.json = (content) -> #make json respond in the format we expect and preserve flashes
            flashes = req.flash() || []
            body = {content: content, flash: flashes, hasError: !!flashes.error?.length}
            shadow.json.apply(res, [body])

        res.redirect = (url) -> #make redirect behave properly when we expect a json response
            if req.xhr
                flashes = req.flash() || []
                body = {content: null, flash: flashes, redirect: url}
                shadow.json.apply(res, [body])
            else
                shadow.redirect.apply(res, [url])

        next()
    )

    app.use('/static', require('less-middleware')({
        src: path.join(skin, 'public'),
        dest: path.join(skin, 'compiled')
    }))
    app.use('/static', require('connect-coffee-script')({
        src: path.join(skin, 'public'),
        dest: path.join(skin, 'compiled')
    }))

    app.use('/static', express.static(path.join(skin, 'public')))
    app.use('/static', express.static(path.join(skin, 'compiled')))

    app.use('/slow', express.timeout(1))  # per section timeouts!
    app.use(app.router)

    app.use((req, res, next) ->
        res.status(404)

        # respond with html page
        if (req.accepts('html'))
            res.render('error/404.html', { url: req.url })
            return

        # respond with json
        if (req.accepts('json'))
            res.send({ error: 'Not found' })
            return

        # default to plain-text. send()
        res.type('txt').send('Not found')
    )
  # maybe this instead? ->  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
    app.use((err, req, res, next) ->
        # we may use properties of the error object
        # here and next(err) appropriately, or if
        # we possibly recovered from the error, simply next().
        res.status(err.status || 500)
        res.render('error/500.html', { error: err })
    )

