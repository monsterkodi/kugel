
# 00000000   000       0000000   000   000  00000000  000000000
# 000   000  000      000   000  0000  000  000          000   
# 00000000   000      000000000  000 0 000  0000000      000   
# 000        000      000   000  000  0000  000          000   
# 000        0000000  000   000  000   000  00000000     000   

{ deg2rad, pos, log, _ } = require 'kxk'

Matter  = require 'matter-js'

class Planet

    constructor: (@physics, opt) ->
        
        @center = opt.center ? pos 0,0
        @random = opt.random ? 10
        @planet = opt.planet ? 'surface'
        
        switch @planet
            
            when 'surface2'
                @gravity    = 0.5
                @radius     = 1900
                @fillStyle  = '#666'
                @plates     = 20
                @maxZoom    = 64

            when 'surface'
                @gravity    = 0.75
                @radius     = 1100
                @fillStyle  = 'rgb(143,141,255)'
                @plates     = 20
                @maxZoom    = 64
                
        for i in [0...@plates]
            angle = i * 360/@plates
            p = pos(0,@radius).rotate angle
            surface = @physics.newBody @planet, 
                x:       @center.x+p.x
                y:       @center.y+p.y
                scale:   1
                static:  true
                maxZoom: @maxZoom
                
            Matter.Body.setAngle surface, deg2rad 180+angle+ _.random -2*@random, @random, true
            surface.collisionFilter.category = 2
            surface.collisionFilter.mask     = 0xffff
        
        falloff    = opt.falloff ? 1
        @gravMax   = @radius * (4 + falloff)
        @gravConst = @radius * 4
        @gravMaxSquare = @gravMax * @gravMax
                    
    #  0000000   00000000    0000000   000   000  000  000000000  000   000  
    # 000        000   000  000   000  000   000  000     000      000 000   
    # 000  0000  0000000    000000000   000 000   000     000       00000    
    # 000   000  000   000  000   000     000     000     000        000     
    #  0000000   000   000  000   000      0      000     000        000     
    
    gravityAt: (position) ->
        
        bodyToCenter = pos(position).to(@center)
        if bodyToCenter.square() < @gravMaxSquare
            baseGravity = 0.001 * @gravity
            distance = bodyToCenter.length()
            if distance < @gravConst
                distanceFactor = 1
            else
                distanceFactor = (distance-@gravConst)/(@gravMax-@gravConst)
                distanceFactor = (1 + Math.cos(distanceFactor * Math.PI))/2
            return bodyToCenter.normal().times distanceFactor * baseGravity
        else
            pos 0,0
                    
    # 0000000    00000000    0000000   000   000  
    # 000   000  000   000  000   000  000 0 000  
    # 000   000  0000000    000000000  000000000  
    # 000   000  000   000  000   000  000   000  
    # 0000000    000   000  000   000  00     00  
    
    draw: (ctx) ->
        
        ctx.fillStyle = @fillStyle
        ctx.beginPath()
        ctx.ellipse @center.x, @center.y, @radius, @radius, 0, 0, 2 * Math.PI
        ctx.fill()
                
        ctx.lineWidth = 2*@physics.zoom
        ctx.strokeStyle = 'rgba(64,64,128,0.8)'
        ctx.beginPath()
        ctx.ellipse @center.x, @center.y, @gravConst, @gravConst, 0, 0, 2 * Math.PI
        ctx.stroke()

        ctx.strokeStyle = 'rgba(32,32,64,0.8)'
        ctx.beginPath()
        ctx.ellipse @center.x, @center.y, @gravMax, @gravMax, 0, 0, 2 * Math.PI
        ctx.stroke()
        
module.exports = Planet
