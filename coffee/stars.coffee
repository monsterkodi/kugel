
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
        @zoom  = 1
        
        w = sw()
        h = sh()
        
        for i in [0...256]
            @stars.push 
                size:   (i%4)+2
                depth:  i%4
                color:  ['#22b', '#33c', '#44d', '#55e'][i%4]
                center: pos _.random(-w/2, w/2, true), _.random(-h/2, h/2, true)
                
    # 0000000    00000000    0000000   000   000  
    # 000   000  000   000  000   000  000 0 000  
    # 000   000  0000000    000000000  000000000  
    # 000   000  000   000  000   000  000   000  
    # 0000000    000   000  000   000  00     00  
    
    draw: (rect, zoom, velocity) ->

        if zoom != @zoom then @setZoom zoom, rect
        
        center = rect.center()
        outerScale = zoom >= 1 and (1.2 * zoom) or 1/zoom
        outer = rect.copy().scale outerScale
        s = outer.minRadiusSquare()
        o = outer.maxRadiusSquare()
        
        for star in @stars
            
            np = star.center.minus velocity.times (star.depth+1)/8

            if np.square() > s
                if outer.intersectLine center, np
                    angle = _.random -60, 60, true
                    scale = _.random o, o*1.1, true
                    dir = center.plus velocity.normal().rotate angle
                    np = outer.intersectLine center, dir.scale 2*o
                    np.scale _.random 0.8, 1, true
                
            star.center = np
            
            @world.ctx.fillStyle = star.color
            @world.ctx.fillRect star.center.x, star.center.y, star.size*@zoom, star.size*@zoom
            
        @world.ctx.lineWidth = 1
        @world.ctx.strokeStyle = star.color
        @world.ctx.beginPath()
        @world.ctx.moveTo rect.topLeft().x,  rect.topLeft().y
        @world.ctx.lineTo rect.topRight().x, rect.topRight().y
        @world.ctx.lineTo rect.botRight().x, rect.botRight().y
        @world.ctx.lineTo rect.botLeft().x,  rect.botLeft().y
        @world.ctx.lineTo rect.topLeft().x,  rect.topLeft().y
        @world.ctx.stroke()
          
    # 0000000   0000000    0000000   00     00  
    #    000   000   000  000   000  000   000  
    #   000    000   000  000   000  000000000  
    #  000     000   000  000   000  000 0 000  
    # 0000000   0000000    0000000   000   000  
    
    setZoom: (zoom, rect) ->
        
        if zoom >= 1
            diff = zoom - @zoom
            # log @zoom, zoom, diff
            for star in @stars
                star.center = rect.randomPos()
            @zoom = zoom
        else @zoom = 1
        
module.exports = Stars
