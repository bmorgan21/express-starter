mongoose = require('mongoose')
models = require('../models')

exports.configure = (app) ->
    mongoose.connect('mongodb://localhost/stash')
    models.init(mongoose)
