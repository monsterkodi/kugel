
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
        
        outer = rect.copy().scale(zoom >= 1 and 1 or 1/zoom)
        s = outer.minRadiusSquare()
        o = outer.maxRadiusSquare()

        for star in @stars
            
            np = star.center.minus velocity.times (star.depth+1)/8

            if np.square() > s
                if not outer.contains np
                    if velocity.isZero()
                        dir = pos(0,1).rotate _.random 0, 360, true
                    else
                        dir = velocity.normal().rotate _.random -80, 80, true
                    np = outer.intersectLine pos(0,0), dir.scale o

            star.center = np
            
            @world.ctx.fillStyle = star.color   
            @world.ctx.fillRect star.center.x, star.center.y, star.size*@zoom, star.size*@zoom
            
    # 0000000   0000000    0000000   00     00  
    #    000   000   000  000   000  000   000  
    #   000    000   000  000   000  000000000  
    #  000     000   000  000   000  000 0 000  
    # 0000000   0000000    0000000   000   000  
    
    setZoom: (zoom, rect) ->
        
        if zoom >= 1
            
            diff = (zoom*zoom) / (@zoom*@zoom)
            
            if diff > 1
                part = 1 - (1/diff)
                for i in @randomIndices @stars.length, part
                    dir = pos(0,1).rotate _.random 0, 360, true
                    @stars[i].center = rect.intersectLine pos(0,0), dir.scale rect.maxRadiusSquare()
                    f = 1-@zoom/zoom
                    @stars[i].center.scale 1-_.random 0, f, true
            else
                for star in @stars
                    if not rect.contains star.center
                        star.center = rect.randomPos()
                    
            @zoom = zoom
        else @zoom = 1
        
    randomIndices: (total, part=1) ->
        
        indices = _.shuffle _.range total
        indices = indices.slice 0, Math.min total, part * total
        indices
        
module.exports = Stars
