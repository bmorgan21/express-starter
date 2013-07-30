process.on('uncaughtException', (err) ->
    console.error(err.stack)
    process.exit()
)
require('coffee-script')
express = require('express')
middleware = require('./config/middleware')
routing = require('./config/routing')
templating = require('./config/templating')
database = require('./config/database')

app = express()

templating.configure(app)
middleware.configure(app, '.')
routing.configure(app)
database.configure(app)

app.listen(app.get('port'), () ->
    console.log('Listening on port ' + app.get('port'))
)