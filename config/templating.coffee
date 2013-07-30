nunjucks = require('nunjucks')
path = require('path')

exports.configure = (app) ->
    env = new nunjucks.Environment(new nunjucks.FileSystemLoader(['public/tpl', 'templates']))
    env.express(app)

    exports.env = env
