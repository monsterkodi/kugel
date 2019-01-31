
#  0000000   0000000   00000000   
# 000       000   000  000   000  
# 000       000000000  0000000    
# 000       000   000  000   000  
#  0000000  000   000  000   000  

{ deg2rad, rad2deg, elem, fade, fadeAngles, first, pos, sw, sh, log, _ } = require 'kxk'

intersect = require './intersect'
Thruster  = require './thruster'
Vehicle   = require './vehicle'
Matter    = require 'matter-js'

class Car extends Vehicle

    constructor: (kugel, opt) ->

        super kugel
        
        position = opt?.position ? pos 0,0
        angle    = opt?.angle ? 0 
        
        @name = 'car'
        
        @thrust = 0
        @steer  = pos 0,0
        
        @body = @kugel.physics.newBody 'car', x:position.x, y:position.y
        @body.collisionFilter.category = 4
        @body.collisionFilter.mask     = 7
        @body.setAngle deg2rad angle if angle
        
        t1p = position.plus pos(-22,25).rotate angle
        t2p = position.plus pos( 22,25).rotate angle
        @tire1 = @kugel.physics.newBody 'tire', x:t1p.x, y:t1p.y
        @tire2 = @kugel.physics.newBody 'tire', x:t2p.x, y:t2p.y
        
        @tire1.frictionStatic = 2
        @tire2.frictionStatic = 2
        @tire1.friction = 1
        @tire2.friction = 1
                
        @thrusters.left  = new Thruster @kugel.physics, @body, pos(-19.5,5), pos(-1,0).rotate -10
        @thrusters.right = new Thruster @kugel.physics, @body, pos(+19.5,5), pos(1,0).rotate  10
        @thrusters.down  = new Thruster @kugel.physics, @body, pos(  0,16.5), pos(0,1)
        
        dw1  = pos(-1,13).rotate angle
        dw2  = pos( 1,13).rotate angle
        m1p  = pos(-14,9).rotate angle
        m2p  = pos( 14,9).rotate angle
        t1p  = pos(-10,-7).rotate angle
        t2p  = pos( 10,-7).rotate angle
        
        visible = true
        
        @constraints = []
        @addConstraint bodyA:@body, bodyB:@tire1, pointA:m1p, stiffness:   1, damping:   0, render: visible: visible
        @addConstraint bodyA:@body, bodyB:@tire2, pointA:m2p, stiffness:   1, damping:   0, render: visible: visible
        @addConstraint bodyA:@body, bodyB:@tire1, pointA:dw1, stiffness: 0.2, damping: 0.1, render: visible: visible
        @addConstraint bodyA:@body, bodyB:@tire2, pointA:dw2, stiffness: 0.2, damping: 0.1, render: visible: visible
        @addConstraint bodyA:@body, bodyB:@tire1, pointA:t1p, stiffness: 0.2, damping: 0.1, render: visible: visible
        @addConstraint bodyA:@body, bodyB:@tire2, pointA:t2p, stiffness: 0.2, damping: 0.1, render: visible: visible
        
    addConstraint: (opt) ->
        constraint = Matter.Constraint.create opt
        Matter.World.add @kugel.physics.engine.world, constraint
        @constraints.push constraint
                
    del: ->
        for constraint in @constraints
            Matter.Composite.remove @kugel.physics.engine.world, constraint
        super()
        @kugel.physics.delBody @tire1
        @kugel.physics.delBody @tire2
        
    # 0000000    00000000  00000000   0000000   00000000   00000000  000000000  000   0000000  000   000  
    # 000   000  000       000       000   000  000   000  000          000     000  000       000  000   
    # 0000000    0000000   000000    000   000  0000000    0000000      000     000  000       0000000    
    # 000   000  000       000       000   000  000   000  000          000     000  000       000  000   
    # 0000000    00000000  000        0000000   000   000  00000000     000     000   0000000  000   000  
    
    beforeTick: (delta) ->
        
        super delta
                        
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
        else if @kugel.planet?
            downAngle = @up().rotation @kugel.planet.center.to @pos()
            @body.setAngularVelocity -downAngle/1000
                
    #  0000000   00000000  000000000  00000000  00000000   000000000  000   0000000  000   000  
    # 000   000  000          000     000       000   000     000     000  000       000  000   
    # 000000000  000000       000     0000000   0000000       000     000  000       0000000    
    # 000   000  000          000     000       000   000     000     000  000       000  000   
    # 000   000  000          000     00000000  000   000     000     000   0000000  000   000  
    
    afterTick: (delta) ->

        @thrusters.left.thrust  = Math.max 0, +@steer.x
        @thrusters.right.thrust = Math.max 0, -@steer.x
        @thrusters.down.thrust  = @boosts and 1 or Math.max 0, -@steer.y
        
        super delta

    # 0000000    00000000    0000000   000   000  
    # 000   000  000   000  000   000  000 0 000  
    # 000   000  0000000    000000000  000000000  
    # 000   000  000   000  000   000  000   000  
    # 0000000    000   000  000   000  00     00  
    
    draw: (ctx) ->
        
        super ctx
        
        ctx.save()
        ctx.beginPath()
        ctx.strokeStyle = '#fff'
        ctx.lineWidth = 5
        ctx.moveTo @tire1.position.x, @tire1.position.y
        ctx.lineTo @body.position.x,  @body.position.y 
        ctx.lineTo @tire2.position.x, @tire2.position.y
        ctx.stroke()
        ctx.restore()
        
    show: -> 
        super()
        @physics.addBody @tire1
        @physics.addBody @tire2
        
    hide: -> 
        super()
        @physics.delBody @tire1
        @physics.delBody @tire2

    setPos: (position) ->
        delta = @pos().to position
        super position
        @tire1.setPosition delta.plus pos @tire1.position
        @tire2.setPosition delta.plus pos @tire2.position
        
    # 00000000   0000000   00000000    0000000  00000000  
    # 000       000   000  000   000  000       000       
    # 000000    000   000  0000000    000       0000000   
    # 000       000   000  000   000  000       000       
    # 000        0000000   000   000   0000000  00000000  
    
    applyForce: (direction) ->
                
        zoomFactor = 1 + (@kugel.physics.zoom-1)/8
        force = direction.rotate(rad2deg @body.angle).times zoomFactor
        @body.applyForce force
        @tire1.applyForce force.times 0.28
        @tire2.applyForce force.times 0.28
                                                            
module.exports = Car
