
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
        @jumpDelay  = 0
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
        
        force = @sideDir().times 0.2 * Math.abs(@thrust) * (1 + (zoom-1)/4)
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
            
        if @jumping
            @jumping -= delta
            @jumping = 0 if @jumping < 0
            if @jumpDelay > 0 then @jumpDelay -= delta
            if @jumpDelay <= 0
                @smokeJump()
            
    draw: (size, scale, w, h) ->
        
        zoom = @kugel.physics.zoom
        carx = @body.position.x
        cary = @body.position.y
        
        @kugel.ctx.save()
        @kugel.ctx.beginPath()
        @kugel.ctx.strokeStyle = '#fff'
        @kugel.ctx.lineWidth = 5
        @kugel.ctx.moveTo (size.x/2 + @tire1.position.x - carx)/zoom, (size.y/2 + @tire1.position.y - cary)/zoom
        @kugel.ctx.lineTo (size.x/2 + @body.position.x  - carx)/zoom, (size.y/2 + @body.position.y  - cary)/zoom
        @kugel.ctx.lineTo (size.x/2 + @tire2.position.x - carx)/zoom, (size.y/2 + @tire2.position.y - cary)/zoom
        @kugel.ctx.stroke()
        @kugel.ctx.restore()
                
        tail = @side -0.64
        @kugel.ctx.save()
        @kugel.ctx.translate (size.x/2 + tail.x - carx)/zoom, (size.y/2 + tail.y - cary)/zoom
        @kugel.ctx.rotate @body.angle + deg2rad 90 - (@thrust < 0 and -14 or 14)
        @kugel.ctx.scale scale.x * @thrust, scale.y * @thrust
        @kugel.ctx.drawImage @flame, -@flame.width/2, 0
        @kugel.ctx.restore()
        
        if @jumping
            tail = @pos().minus @up().times 16
            @kugel.ctx.save()
            @kugel.ctx.translate (size.x/2 + tail.x - carx)/zoom, (size.y/2 + tail.y - cary)/zoom
            @kugel.ctx.rotate @body.angle
            @kugel.ctx.scale scale.x * 1, scale.y * 1
            @kugel.ctx.drawImage @flame, -@flame.width/2, 0
            @kugel.ctx.restore()
            
    turn: (leftOrRight, active) -> @rot[leftOrRight] = active and 2 or 0
    jump: ->
        if not @jumping
            @jumping = 500
            force = @up().times 20
            @body.applyForce force
        
    brake: (@brakes) ->         
     
    pos: -> pos @body.position
    dir: -> 
        x = @thrust >= 0 and 1 or -1
        pos(x,0).rotate rad2deg @body.angle
    up: -> pos(0,-1).rotate rad2deg @body.angle
    
    sideDir: -> 
        if @thrust >= 0
            dir = pos(1,0).rotate rad2deg(@body.angle) - 14
        else
            dir = pos(-1,0).rotate rad2deg(@body.angle) + 14
            
    side: (scale=1) -> 
        
        @pos().plus @sideDir().scale 30*scale
        
    #  0000000  00     00   0000000   000   000  00000000  
    # 000       000   000  000   000  000  000   000       
    # 0000000   000000000  000   000  0000000    0000000   
    #      000  000 0 000  000   000  000  000   000       
    # 0000000   000   000   0000000   000   000  00000000  
    
    smoke: ->

        if @puffs.length >= @maxPuffs
            @kugel.physics.delBody @puffs.shift()
        
        p = @side -0.4-Math.abs @thrust
        puff = @kugel.physics.addBody 'puff', x:p.x, y:p.y

        puff.compOp = 'lighter'
        puff.collisionFilter.category = 8
        puff.collisionFilter.mask     = 10
        
        puff.setDensity 0.0000001
        puff.restitution = 0
        puff.maxScale = Math.abs(@thrust) * 32 * _.random 0.5, 1, true
        puff.lifespan = Math.max 2000, Math.abs(@thrust)*2*3000
        puff.lifetime = puff.lifespan
        
        puff.tick = @onPuffTick
          
        puff.setVelocity @sideDir().times(-1-3*Math.abs(@thrust)).plus pos @body.velocity

        @smokeDelay = 300 - Math.min(1, 2*Math.abs(@thrust)) * 260
        
        @puffs.push puff

    smokeJump: ->

        if @puffs.length >= @maxPuffs
            @kugel.physics.delBody @puffs.shift()
        
        p = @pos().plus @up().times -16
        puff = @kugel.physics.addBody 'puff', x:p.x, y:p.y

        puff.compOp = 'lighter'
        puff.collisionFilter.category = 8
        puff.collisionFilter.mask     = 10
        
        puff.setDensity 0.0000001
        puff.restitution = 0
        puff.maxScale = 20 * _.random 0.5, 1, true
        puff.lifespan = 3000
        puff.lifetime = puff.lifespan
        
        puff.tick = @onPuffTick
          
        puff.setVelocity @up().times(-4).plus pos @body.velocity
        puff.setAngle @body.angle

        @jumpDelay = 40
        
        @puffs.push puff
        
    onPuffTick: (delta) ->
        f        = 1 - @lifetime/@lifespan
        @scale   = @maxScale * (Math.log(f+0.2)+2)/2
        @opacity = 0.25 * @lifetime/@lifespan
        
module.exports = Car
