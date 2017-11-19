
#  0000000  000000000   0000000   00000000    0000000
# 000          000     000   000  000   000  000     
# 0000000      000     000000000  0000000    0000000 
#      000     000     000   000  000   000       000
# 0000000      000     000   000  000   000  0000000 

{ elem, last, sw, sh, pos, log, _ } = require 'kxk'

{ profile } = require './utils'

svg = require './svg'

class Stars

    constructor: (@kugel) ->

        @stars = []

        w = sw()
        h = sh()
        
        for i in [0...128]
            @stars.push 
                size:   (i%4)+2
                depth:  i%4
                color:  ['#22b', '#33c', '#44d', '#55e'][i%4]
                center: pos _.random(0, w, true), _.random(0, h, true)
                
    draw: ->

        return if not @kugel.ship
        
        w = sw()
        h = sh()
        
        # prof = profile 'stars'

        for star in @stars
            
            cx = star.center.x - @kugel.ship.body.velocity.x / (8 - star.depth) #* @kugel.physics.zoom
            cy = star.center.y - @kugel.ship.body.velocity.y / (8 - star.depth) #* @kugel.physics.zoom
             
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
            
            @kugel.ctx.fillStyle = star.color
            @kugel.ctx.fillRect parseInt(star.center.x), parseInt(star.center.y), star.size, star.size
        
        # prof.end()
        
module.exports = Stars
