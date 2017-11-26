
#  0000000   0000000   00000000   
# 000       000   000  000   000  
# 000       000000000  0000000    
# 000       000   000  000   000  
#  0000000  000   000  000   000  

{ deg2rad, rad2deg, elem, fade, fadeAngles, first, pos, sw, sh, log, _ } = require 'kxk'

svg       = require './svg'
intersect = require './intersect'
Thruster  = require './thruster'
Matter    = require 'matter-js'

class Car

    constructor: (@kugel) ->

        @pad        = @kugel.pad
        @thrust     = 0
        @angle      = 0
        @brakes     = false
        @boosts     = false
        @steer      = pos 0,0
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
        
        @thrusters = {}
        
        @thrusters.left  = new Thruster @kugel.physics, @body, pos(-19.5,5), pos(-1,0).rotate -10
        @thrusters.right = new Thruster @kugel.physics, @body, pos(+19.5,5), pos(1,0).rotate  10
        @thrusters.down  = new Thruster @kugel.physics, @body, pos(  0,16.5), pos(0,1)

        constraint = Matter.Constraint.create bodyA:@tire2, bodyB:@tire1, stiffness: 0.1, damping: 0.1, render: visible: true
        Matter.World.add @kugel.physics.engine.world, constraint 
        
        constraint = Matter.Constraint.create bodyA:@body, bodyB:@tire1, render: visible: true
        Matter.World.add @kugel.physics.engine.world, constraint

        constraint = Matter.Constraint.create bodyA:@body, bodyB:@tire1, pointA:pos(-10,1), stiffness: 0.2, damping: 0.1, render: visible: true
        Matter.World.add @kugel.physics.engine.world, constraint
        
        constraint = Matter.Constraint.create bodyA:@body, bodyB:@tire2, pointA:pos(10,1), stiffness: 0.2, damping: 0.1, render: visible: true
        Matter.World.add @kugel.physics.engine.world, constraint
        
        constraint = Matter.Constraint.create bodyA:@body, bodyB:@tire2, render: visible: true
        Matter.World.add @kugel.physics.engine.world, constraint

    # 0000000    00000000    0000000   000   000  
    # 000   000  000   000  000   000  000 0 000  
    # 000   000  0000000    000000000  000000000  
    # 000   000  000   000  000   000  000   000  
    # 0000000    000   000  000   000  00     00  
    
    draw: ->
        ctx = @kugel.ctx      
        ctx.save()
        ctx.beginPath()
        ctx.strokeStyle = '#fff'
        ctx.lineWidth = 5
        ctx.moveTo @tire1.position.x, @tire1.position.y
        ctx.lineTo @body.position.x,  @body.position.y 
        ctx.lineTo @tire2.position.x, @tire2.position.y
        ctx.stroke()
        ctx.restore()

        ctx.save()
        ctx.translate @body.position.x, @body.position.y
        ctx.rotate @body.angle
        for key,thruster of @thrusters
            thruster.draw ctx
        ctx.restore()
        
    # 000000000  000   0000000  000   000  
    #    000     000  000       000  000   
    #    000     000  000       0000000    
    #    000     000  000       000  000   
    #    000     000   0000000  000   000  
    
    beforeTick: (delta) ->

        @rot.left  = @pad.button('L1').pressed and 2 or 0
        @rot.right = @pad.button('R1').pressed and 2 or 0
        
        @steer  = pos @pad.axis('leftX'), @pad.axis('leftY')
        @thrust = @steer.length()
                
        @brakes = @pad.button('square').pressed or @pad.button('L2').pressed
        @boosts = false
        
        if @pad.button('cross').down
            @boosts = true
            direction = pos 0,-1
            @applyForce direction.times 35
            
        if @pad.button('L3').down and not @steer.isZero 0.01
            @boosts   = true
            direction = @steer.copy()
            @applyForce direction.times 35
            
        if @brakes
            @thrust = 0
            @body.setVelocity pos(@body.velocity).times 0.98
        
        @applyForce @steer.copy()

        rotLeft  = @rot.left  * (@brakes and 1.3 or 2)
        rotRight = @rot.right * (@brakes and 1.3 or 2)
        
        if Math.abs(rotRight - rotLeft)
            @body.setAngularVelocity 0
            @body.setAngle @body.angle + deg2rad(rotRight - rotLeft)
        else    
            bodyAngle = rad2deg @body.angle
            gravAngle = @kugel.planet.center.to(@pos()).rotation(pos 0,-1)
            if Math.abs(bodyAngle - gravAngle) > 15
                @body.setAngle deg2rad fadeAngles bodyAngle, gravAngle, 0.45

    afterTick: (delta) ->

        @thrusters.left.thrust  = Math.max 0, +@steer.x
        @thrusters.right.thrust = Math.max 0, -@steer.x
        @thrusters.down.thrust  = @boosts and 1 or Math.max 0, -@steer.y
        
        for key,thruster of @thrusters
            thruster.afterTick delta
                
    # 00000000   0000000   00000000    0000000  00000000  
    # 000       000   000  000   000  000       000       
    # 000000    000   000  0000000    000       0000000   
    # 000       000   000  000   000  000       000       
    # 000        0000000   000   000   0000000  00000000  
    
    applyForce: (direction) ->
                
        zoomFactor = 1 + (@kugel.physics.zoom-1)/8
        force = direction.rotate(rad2deg @body.angle).times @kugel.planet.gravity * zoomFactor
        @body.applyForce force
        @tire1.applyForce force.times 0.28
        @tire2.applyForce force.times 0.28
                                                        
    pos: -> pos @body.position
    
module.exports = Car
