querystring = require('querystring')
controllers = require('../controllers')
authController = controllers.auth
homeController = controllers.home

requiresAuth = (req, res, next) ->
    unless (req.user)
        res.redirect('/auth/login/?' + querystring.stringify({r: req.originalUrl}))
    else
        next()

exports.configure = (app) ->
    app.get('/', homeController.index)

    # Redirect the user to Google for authentication.  When complete, Google
    # will redirect the user back to the application at
    #     /auth/google/return
    app.get('/auth/login/', authController.login)

    # Google will redirect the user to this URL after authentication.  Finish
    # the process by verifying the assertion.  If valid, the user will be
    # logged in.  Otherwise, authentication has failed.
    app.get('/auth/callback/', authController.login_callback)

    app.get('/auth/logout/', authController.logout)
