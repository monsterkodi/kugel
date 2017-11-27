
#  0000000  000   000  000  00000000 
# 000       000   000  000  000   000
# 0000000   000000000  000  00000000 
#      000  000   000  000  000      
# 0000000   000   000  000  000      

{ deg2rad, rad2deg, elem, fade, fadeAngles, first, pos, sw, sh, log, _ } = require 'kxk'

intersect = require './intersect'
Vehicle   = require './vehicle'
Thruster  = require './thruster'
Matter    = require 'matter-js'

class Ship extends Vehicle

    constructor: (@kugel) ->

        @name = 'ship'
        super @kugel
        
        @thrust     = 0
        @angle      = 0
        @shoots     = false
        @lasers     = false
        @shootDelay = 0
        @bullets    = []
        @maxBullets = 100
                
        @body = @kugel.physics.newBody 'ship', x:0, y:0
        @body.collisionFilter.category = 4
        @body.collisionFilter.mask     = 7
        
        @thrusters.down = new Thruster @physics, @body, pos(0,22), pos(0,1)
        
    # 0000000    00000000  00000000   0000000   00000000   00000000  000000000  000   0000000  000   000  
    # 000   000  000       000       000   000  000   000  000          000     000  000       000  000   
    # 0000000    0000000   000000    000   000  0000000    0000000      000     000  000       0000000    
    # 000   000  000       000       000   000  000   000  000          000     000  000       000  000   
    # 0000000    00000000  000        0000000   000   000  00000000     000     000   0000000  000   000  
    
    beforeTick: (delta) ->

        super delta
        
        zoom = @kugel.physics.zoom
        @angle = rad2deg @body.angle

        @lasers = not @lasers if @pad.button('triangle').down
        @shoots = @pad.button('cross').pressed or @pad.button('R2').pressed
        if not @shoots then @shootDelay = 0
        
        if @thrust - 0.1 > 0
            @angle  = fadeAngles @angle, @steer.rotation(pos 0,-1), @thrust/10
            @body.setAngularVelocity 0
        else
            @thrust = 0
        
        if @brakes
            @thrust = 0
            @body.setVelocity pos(@body.velocity).times 0.95
                    
        @body.applyForce @dir().times @thrust * (1 + (zoom-1)/4)

        rotLeft  = @rot.left  * (@brakes and 0.1 or 1)
        rotRight = @rot.right * (@brakes and 0.1 or 1)
        
        if Math.abs(rotRight - rotLeft)
            @body.setAngularVelocity 0
            @angle += rotRight - rotLeft
            
        @body.setAngle deg2rad @angle
                    
    #  0000000   00000000  000000000  00000000  00000000   000000000  000   0000000  000   000  
    # 000   000  000          000     000       000   000     000     000  000       000  000   
    # 000000000  000000       000     0000000   0000000       000     000  000       0000000    
    # 000   000  000          000     000       000   000     000     000  000       000  000   
    # 000   000  000          000     00000000  000   000     000     000   0000000  000   000  
    
    afterTick: (delta) ->

        if @shootDelay > 0 then @shootDelay -= delta
        if @shoots and @shootDelay <= 0
            @shoot()

        @thrusters.down.thrust = @boosts and 1 or Math.max 0, @thrust
        
        super delta
            
    # 0000000    00000000    0000000   000   000  
    # 000   000  000   000  000   000  000 0 000  
    # 000   000  0000000    000000000  000000000  
    # 000   000  000   000  000   000  000   000  
    # 0000000    000   000  000   000  00     00  
    
    draw: (ctx) ->
        
        super ctx
                
        if @lasers
            
            ctx.save()
            
            tip = @tip()
            tgt = tip.plus @pos().to(tip).scale 10000
            
            hits = Matter.Query.ray @physics.bodies, tip, tgt
            
            if hits.length
                ctx.strokeStyle = '#88f'
                hit = first hits
                tgt = intersect.rayBody(tip, tgt, hit.bodyA) ? tgt
            else
                ctx.strokeStyle = '#22a'
                                
            ctx.beginPath()
            ctx.lineWidth = @physics.zoom
            ctx.moveTo tip.x, tip.y
            ctx.lineTo tgt.x, tgt.y
            ctx.stroke()
            ctx.restore()
                                     
    dir: -> pos(0,-1).rotate rad2deg @body.angle
    tip: (scale=1) -> @pos().plus @dir().scale 30*scale
        
    #  0000000  000   000   0000000    0000000   000000000  
    # 000       000   000  000   000  000   000     000     
    # 0000000   000000000  000   000  000   000     000     
    #      000  000   000  000   000  000   000     000     
    # 0000000   000   000   0000000    0000000      000     
    
    shoot: ->
        
        if @bullets.length >= @maxBullets
            @kugel.physics.delBody @bullets.shift()
        
        bullet = @kugel.physics.newBody 'bullet', @tip()
        bullet.setDensity 10
        bullet.restitution = 1
          
        bullet.setVelocity @dir().times(10).plus pos @body.velocity
        bullet.setAngle @body.angle

        @shootDelay = 100
        
        @bullets.push bullet
        
module.exports = Ship
