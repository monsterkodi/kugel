
#  0000000  000000000   0000000   00000000    0000000
# 000          000     000   000  000   000  000     
# 0000000      000     000000000  0000000    0000000 
#      000     000     000   000  000   000       000
# 0000000      000     000   000  000   000  0000000 

{ deg2rad, elem, last, sw, sh, pos, log, _ } = require 'kxk'

{ profile } = require './utils'

svg       = require './svg'
intersect = require './intersect'

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
                
    draw: (rect, velocity) ->

        center = rect.center()
        outer  = rect.copy().scale 1.2
        s = rect.minRadiusSquare()
        o = rect.maxRadiusSquare()
        z = Math.max 1, @world.physics.zoom
        
        for star in @stars
            
            np = star.center.minus velocity.times (star.depth+1)/8

            if np.distSquare(center) > s
                if outer.intersectLine center, np
                    angle = _.random -60, 60, true
                    scale = _.random o, o*1.1, true
                    np = rect.intersectLine center, center.plus velocity.normal().rotate(angle).scale o
                    np.scale _.random 1, 1.19, true
                
            star.center = np
            
            @world.ctx.fillStyle = star.color
            @world.ctx.fillRect star.center.x, star.center.y, star.size*z, star.size*z
            
        @world.ctx.lineWidth = 1
        @world.ctx.strokeStyle = star.color
        @world.ctx.beginPath()
        @world.ctx.moveTo rect.topLeft().x,  rect.topLeft().y
        @world.ctx.lineTo rect.topRight().x, rect.topRight().y
        @world.ctx.lineTo rect.botRight().x, rect.botRight().y
        @world.ctx.lineTo rect.botLeft().x,  rect.botLeft().y
        @world.ctx.lineTo rect.topLeft().x,  rect.topLeft().y
        @world.ctx.stroke()
            
module.exports = Stars
