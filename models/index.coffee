user = require('./user')

exports.init = (db) ->
    exports.User = db.model('User', user.schema)
