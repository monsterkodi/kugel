path    = require 'path'
process = require 'process'

module.exports = (unresolved) ->
    p = unresolved.replace /\~/, process.env.HOME
    p = path.normalize p
    p = path.resolve p
    p
