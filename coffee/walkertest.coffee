
resolve = require './tools/resolve'
walkDir = require 'walkdir'
fmt     = require 'format'
fs      = require 'fs'
moment  = require 'moment'
chalk   = require 'chalk'
nedb    = require 'nedb'
path    = require 'path'

log     = console.log

jsonStr = (a) -> JSON.stringify a, null, " "

startTime = moment()
timeSinceStart = () -> moment().subtract(startTime).format('m [m] s [s]')

fs.readFile resolve('~/.kugel.json'), (err,data) ->
    if err? then log err
    else
        log fmt('loaded json at %s', timeSinceStart())    
        dirs = JSON.parse(data)
        log fmt('parsed json at %s', timeSinceStart())    
        d1 = dirs['/Users/kodi']
        log fmt('%s found in json at %s', d1.files.length, timeSinceStart())    
        d2 = dirs['/Users/kodi/Projects']
        log fmt('%s found in json at %s', d2.files.length, timeSinceStart())    
