
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

walk = walkDir "/", 
    "max_depth": Infinity
    
walk.ignore ["/Volumes"]
    
dirs = 
    '/': 
        files: []
        dirs: []
        size: 0
        name: '/'
        path: ''
        
shorten = (p, l=80) ->
    if p.length <= l then return p
    p.substr(0,l-3) + '...'
        
calcSize = (dirname) ->
    d = dirs[dirname]
    if d?
        for file in d.files
            d.size += file.size
        for dir in d.dirs
            if dirname == '/'
                d.size += calcSize '/' + dir
            else
                d.size += calcSize dirname + '/' + dir
        return d.size
    log '???', dirname
    0
    
walk.on 'directory', (dirname, stat) ->
    # log chalk.blue.bold dirname
    parent = dirs[path.dirname dirname]
    name = path.basename dirname
    parent.dirs.push name
    dirs[dirname] = 
        files: []
        dirs:  []
        size:  0   
        name:  name
        path:  dirname
        
    process.stdout.clearLine()
    process.stdout.cursorTo(0)
    process.stdout.write shorten dirname

walk.on 'file', (filename, stat) ->
    # log chalk.magenta dirname
    dirname = path.dirname filename
    parent = dirs[dirname]
    parent.files.push 
        name: path.basename filename
        size: stat.size
                
walk.on 'end', ->
    process.stdout.clearLine()
    process.stdout.cursorTo(0)
    log fmt('%d dirs parsed in %s', Object.keys(dirs).length, timeSinceStart())
    calcSize '/'
    log 'total size:', dirs['/'].size
    
    fs.writeFileSync resolve('~/.kugel.json'), JSON.stringify(dirs)
    
    log fmt 'json saved at %s', timeSinceStart()
    
    # db = new nedb
    #     filename: resolve '~/.kugel.db'
    #     autoload: true
    # 
    # log fmt 'db loaded at %s', timeSinceStart()
    # 
    # db.count {}, (err, count) ->
    #     if err? then log err
    #     else log fmt '%d dirs in db at %s', count, timeSinceStart()
            
    # return
    # cnt = 0
    # for dirname, dir of dirs
    #     dir.path = dirname
    #     cnt += 1
    #     db.insert dir, (err, doc) ->
    #         if not doc?._id
    #             log err
    #         else
    #             cnt -= 1
    #             if cnt == 0
    #                 log fmt('data saved at %s', timeSinceStart())
    #                 db.ensureIndex { fieldName: 'path' }, (err) ->
    #                     if err? then log err
    #                 log fmt('index set at %s', timeSinceStart())
    #                 db.count {}, (err, count) ->
    #                     if err? then log err
    #                     else log fmt '%d dirs saved', count
