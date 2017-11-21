
#  0000000  000000000   0000000   00000000    0000000
# 000          000     000   000  000   000  000     
# 0000000      000     000000000  0000000    0000000 
#      000     000     000   000  000   000       000
# 0000000      000     000   000  000   000  0000000 

{ deg2rad, elem, last, sw, sh, pos, log, _ } = require 'kxk'

{ profile } = require './utils'

svg = require './svg'

class Stars

    constructor: (@world) ->

        @stars = []

        w = sw()
        h = sh()
        
        for i in [0...256]
            @stars.push 
                size:   (i%4)+2
                depth:  i%4
                color:  ['#22b', '#33c', '#44d', '#55e'][i%4]
                center: pos _.random(0, w, true), _.random(0, h, true)
                
    draw: (zoom, velocity) ->

        w = sw()
        h = sh()
        
        for star in @stars
            
            cx = star.center.x - velocity.x / (8 - star.depth) / zoom
            cy = star.center.y - velocity.y / (8 - star.depth) / zoom
             
            if cx < 0
                cx = w
                cy = _.random 0, h, true
            else if cx > w
                cx = 0
                cy = _.random 0, h, true
                 
            if cy < 0
                cy = h
                cx = _.random 0, w, true
            else if cy > h
                cy = 0
                cx = _.random 0, w, true
                 
            star.center.x = cx
            star.center.y = cy
            
            @world.ctx.fillStyle = star.color
            @world.ctx.fillRect parseInt(star.center.x), parseInt(star.center.y), star.size, star.size
        
module.exports = Stars
