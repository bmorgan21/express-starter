passport = require('passport')
base = require('./base')

BaseController = base.BaseController

class HomeController extends BaseController
    index: (req, res, next) ->
        res.render('index.html', {})

exports.controller = new HomeController()