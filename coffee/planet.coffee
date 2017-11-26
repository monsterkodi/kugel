
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
                @gravity = 0.5
                @radius  = 1900
                @fillStyle = '#666'
                for i in [0...20]
                    angle = i * 18
                    p = pos(0,@radius).rotate angle
                    surface = @physics.newBody @planet,  x:@center.x+p.x, y:@center.y+p.y, scale: 1, static: true
                    Matter.Body.setAngle surface, deg2rad 180+angle+ _.random -2*@random, @random, true
                    surface.collisionFilter.category = 2
                    surface.collisionFilter.mask     = 0xffff

            when 'surface'
                @gravity = 0.75
                @radius = 1100
                @fillStyle = 'rgb(143,141,255)'
                for i in [0...20]
                    angle = i * 18
                    p = pos(0,@radius).rotate angle
                    surface = @physics.newBody @planet,  x:@center.x+p.x, y:@center.y+p.y, scale: 1, static: true
                    Matter.Body.setAngle surface, deg2rad 180+angle+ _.random -2*@random, @random, true
                    surface.collisionFilter.category = 2
                    surface.collisionFilter.mask     = 0xffff

        @gravMax   = @radius * 4
        @gravConst = @radius * 3
        @gravMaxSquare = @gravMax * @gravMax
                    
    gravityAt: (position) ->
        
        bodyToCenter = pos(position).to(@center)
        if bodyToCenter.square() < @gravMaxSquare
            bodyToCenter.normalize().scale 0.001 * @gravity
            return bodyToCenter
        else
            pos 0,0
                    
    draw: (ctx) ->
        
        ctx.fillStyle = @fillStyle
        ctx.beginPath()
        ctx.ellipse @center.x, @center.y, @radius, @radius, 0, 0, 2 * Math.PI
        ctx.fill()
                
        ctx.lineWidth = 2*@physics.zoom
        ctx.strokeStyle = 'rgba(192,192,255,0.3)'
        ctx.beginPath()
        ctx.ellipse @center.x, @center.y, @gravConst, @gravConst, 0, 0, 2 * Math.PI
        ctx.stroke()

        ctx.strokeStyle = 'rgba(65,65,192,0.3)'
        ctx.beginPath()
        ctx.ellipse @center.x, @center.y, @gravMax, @gravMax, 0, 0, 2 * Math.PI
        ctx.stroke()
        
module.exports = Planet
