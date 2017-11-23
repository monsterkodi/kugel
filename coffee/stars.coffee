
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
                center: pos _.random(-w/2, w/2, true), _.random(-h/2, h/2, true)
                
    draw: (velocity) ->

        s = 1.5 * Math.max sw(), sh()
        z = Math.max 1, @world.physics.zoom
        
        for star in @stars
            
            np = star.center.minus velocity.times (star.depth+1)/8

            if np.length()/z > s/2
                r = z*s/2
                np = velocity.normal().times r
                np.rotate _.random -60, 60, true
#                  
            star.center = np
            
            @world.ctx.fillStyle = star.color
            @world.ctx.fillRect star.center.x, star.center.y, star.size*z, star.size*z
        
module.exports = Stars
