
#  0000000   0000000   00000000   
# 000       000   000  000   000  
# 000       000000000  0000000    
# 000       000   000  000   000  
#  0000000  000   000  000   000  

{ deg2rad, rad2deg, elem, fade, fadeAngles, first, pos, sw, sh, log, _ } = require 'kxk'

svg       = require './svg'
intersect = require './intersect'
Matter    = require 'matter-js'

class Car

    constructor: (@kugel) ->

        @thrust     = 0
        @angle      = 0
        @brakes     = false
        @smokeDelay = 0
        @puffs      = []
        @maxPuffs   = 100
        @speed      = 0
        @rot        = left:0, right:0
        
        @body = @kugel.physics.addBody 'car', x:0, y:0
        @body.collisionFilter.category = 4
        @body.collisionFilter.mask     = 7
        
        @tire1 = @kugel.physics.addBody 'tire', x: -22, y:25
        @tire2 = @kugel.physics.addBody 'tire', x:  22, y:25
        
        @tire1.frictionStatic = 2
        @tire2.frictionStatic = 2
        @tire1.friction = 1
        @tire2.friction = 1

        constraint = Matter.Constraint.create bodyA:@tire2, bodyB:@tire1, stiffness: 0.1, damping: 0.1
        Matter.World.add @kugel.physics.engine.world, constraint 
        
        constraint = Matter.Constraint.create bodyA:@body, bodyB:@tire1
        Matter.World.add @kugel.physics.engine.world, constraint

        constraint = Matter.Constraint.create bodyA:@body, bodyB:@tire1, pointA:pos(-10,1), stiffness: 0.2, damping: 0.1
        Matter.World.add @kugel.physics.engine.world, constraint
        
        constraint = Matter.Constraint.create bodyA:@body, bodyB:@tire2, pointA:pos(10,1), stiffness: 0.2, damping: 0.1
        Matter.World.add @kugel.physics.engine.world, constraint
        
        constraint = Matter.Constraint.create bodyA:@body, bodyB:@tire2
        Matter.World.add @kugel.physics.engine.world, constraint
        
        @flame = svg.image 'flame'

    # 000000000  000   0000000  000   000  
    #    000     000  000       000  000   
    #    000     000  000       0000000    
    #    000     000  000       000  000   
    #    000     000   0000000  000   000  
    
    beforeTick: (delta) ->

        zoom = @kugel.physics.zoom
        @angle = rad2deg @body.angle
                
        @thrust = @kugel.pad.axes?[0] ? 0
        
        if @brakes
            @thrust = 0
            @body.setVelocity pos(@body.velocity).times 0.95
        
        force = @dir().times 0.2 * Math.abs(@thrust) * (1 + (zoom-1)/4)
        @body.applyForce force
        @tire1.applyForce force.times 0.28
        @tire2.applyForce force.times 0.28

        rotLeft  = @rot.left  * (@brakes and 0.1 or 1)
        rotRight = @rot.right * (@brakes and 0.1 or 1)
        
        if Math.abs(rotRight - rotLeft)
            @body.setAngularVelocity 0
            @angle += rotRight - rotLeft
            @body.setAngle deg2rad @angle
                    
    afterTick: (delta) ->

        if @smokeDelay > 0 then @smokeDelay -= delta
        if Math.abs(@thrust) > 0 and @smokeDelay <= 0
            @smoke()
            
    draw: (size, scale, w, h) ->
        
        zoom  = @kugel.physics.zoom
        shipx = @body.position.x
        shipy = @body.position.y
        
        @kugel.ctx.save()
        @kugel.ctx.beginPath()
        @kugel.ctx.strokeStyle = '#fff'
        @kugel.ctx.lineWidth = 5
        @kugel.ctx.moveTo (size.x/2 + @tire1.position.x - shipx)/zoom, (size.y/2 + @tire1.position.y - shipy)/zoom
        @kugel.ctx.lineTo (size.x/2 + @body.position.x  - shipx)/zoom, (size.y/2 + @body.position.y  - shipy)/zoom
        @kugel.ctx.lineTo (size.x/2 + @tire2.position.x - shipx)/zoom, (size.y/2 + @tire2.position.y - shipy)/zoom
        @kugel.ctx.stroke()
        @kugel.ctx.restore()
                
        tail = @tip -0.7
        @kugel.ctx.save()
        @kugel.ctx.translate (size.x/2 + tail.x - shipx)/zoom, (size.y/2 + tail.y - shipy)/zoom
        @kugel.ctx.rotate @body.angle + deg2rad 90
        @kugel.ctx.scale scale.x * @thrust, scale.y * @thrust
        @kugel.ctx.drawImage @flame, -@flame.width/2, 0
        @kugel.ctx.restore()
            
    turn: (leftOrRight, active) -> @rot[leftOrRight] = active and 2 or 0
    jump: ->
        
    brake: (@brakes) ->         
     
    pos: -> pos @body.position
    dir: -> 
        x = @thrust >= 0 and 1 or -1
        pos(x,0).rotate rad2deg @body.angle
    tip: (scale=1) -> @pos().plus @dir().scale 30*scale
        
    #  0000000  000   000   0000000    0000000   000000000  
    # 000       000   000  000   000  000   000     000     
    # 0000000   000000000  000   000  000   000     000     
    #      000  000   000  000   000  000   000     000     
    # 0000000   000   000   0000000    0000000      000     
    
    smoke: ->
        
        if @puffs.length >= @maxPuffs
            @kugel.physics.delBody @puffs.shift()
        
        puff = @kugel.physics.addBody 'puff', @tip(-0.7-2*Math.abs(@thrust))

        puff.collisionFilter.category = 8
        puff.collisionFilter.mask     = 10
        
        puff.setMass 0.0000000001
        puff.restitution = 0
        puff.maxScale = Math.abs(@thrust)*32
        puff.lifespan = Math.max 2000, Math.abs(@thrust)*2*3000
        puff.lifetime = puff.lifespan
        
        puff.tick = @onPuffTick
          
        puff.setVelocity @dir().times(-1-3*Math.abs(@thrust)).plus pos @body.velocity
        puff.setAngle @body.angle

        @smokeDelay = 300 - Math.min(1, 2*Math.abs(@thrust)) * 260
        
        @puffs.push puff
        
    onPuffTick: (delta) ->
        f        = 1 - @lifetime/@lifespan
        @scale   = @maxScale * (Math.log(f+0.2)+2)/2
        @opacity = 0.25 * @lifetime/@lifespan
        
module.exports = Car
