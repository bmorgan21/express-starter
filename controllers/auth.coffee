passport = require('passport')
base = require('./base')

BaseController = base.BaseController

class AuthController extends BaseController
    login: (req, res, next) ->
        req.session.redirectUrl = req.query['r']
        passport.authenticate('google')(req, res, next)

    login_callback: (req, res, next) ->
        passport.authenticate('google', { successRedirect: req.session.redirectUrl or '/', failureRedirect: '/' })(req, res, next)
        req.session.redirectUrl = null

    logout: (req, res, next) ->
        req.logout()
        res.redirect('/')

exports.controller = new AuthController()