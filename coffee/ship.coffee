
#  0000000  000   000  000  00000000 
# 000       000   000  000  000   000
# 0000000   000000000  000  00000000 
#      000  000   000  000  000      
# 0000000   000   000  000  000      

{ deg2rad, rad2deg, elem, fade, fadeAngles, first, pos, sw, sh, log, _ } = require 'kxk'

svg       = require './svg'
intersect = require './intersect'
Matter    = require 'matter-js'

class Ship

    constructor: (@kugel) ->

        @pad        = @kugel.pad
        @thrust     = 0
        @angle      = 0
        @shoots     = false
        @lasers     = false
        @brakes     = false
        @shootDelay = 0
        @smokeDelay = 0
        @bullets    = []
        @puffs      = []
        @maxBullets = 100
        @maxPuffs   = 100
        @steerDir   = pos 0,0
        @rot        = left:0, right:0
        
        @body = @kugel.physics.addBody 'ship', x:0, y:0
        @body.collisionFilter.category = 4
        @body.collisionFilter.mask     = 7
        
        @flame = svg.image 'flame'

    # 000000000  000   0000000  000   000  
    #    000     000  000       000  000   
    #    000     000  000       0000000    
    #    000     000  000       000  000   
    #    000     000   0000000  000   000  
    
    beforeTick: (delta) ->

        zoom = @kugel.physics.zoom
        @angle = rad2deg @body.angle

        @rot.left  = @pad.button('L1').pressed and 2 or 0
        @rot.right = @pad.button('R1').pressed and 2 or 0
        
        @lasers = not @lasers if @pad.button('triangle').down
        @brakes = @pad.button('square').pressed or @pad.button('L2').pressed
        @shoots = @pad.button('cross').pressed or @pad.button('R2').pressed
        if not @shoots then @shootDelay = 0
        
        @steerDir = pos @pad.axis('leftX'), @pad.axis('leftY')
        
        length = @steerDir.length()
        if length - 0.1 > 0
            @angle  = fadeAngles @angle, @steerDir.rotation(pos 0,-1), length/10
            @thrust = (length - 0.1)/2
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
                    
    afterTick: (delta) ->

        if @shootDelay > 0 then @shootDelay -= delta
        if @shoots and @shootDelay <= 0
            @shoot()

        if @smokeDelay > 0 then @smokeDelay -= delta
        if @thrust > 0 and @smokeDelay <= 0
            @smoke()
            
    # 0000000    00000000    0000000   000   000  
    # 000   000  000   000  000   000  000 0 000  
    # 000   000  0000000    000000000  000000000  
    # 000   000  000   000  000   000  000   000  
    # 0000000    000   000  000   000  00     00  
    
    draw: ->
                
        if @lasers
            @kugel.ctx.save()
            
            tip = @tip()
            tgt = tip.plus @pos().to(tip).scale 10000
            
            hits = Matter.Query.ray @kugel.physics.bodies, tip, tgt
            
            if hits.length
                @kugel.ctx.strokeStyle = '#88f'
                hit = first hits
                tgt = intersect.rayBody(tip, tgt, hit.bodyA) ? tgt
            else
                @kugel.ctx.strokeStyle = '#22a'
                                
            @kugel.ctx.beginPath()
            @kugel.ctx.lineWidth = 1
            @kugel.ctx.moveTo tip.x, tip.y
            @kugel.ctx.lineTo tgt.x, tgt.y
            @kugel.ctx.stroke()
            @kugel.ctx.restore()
                
        tail = @tip -0.7
        @kugel.ctx.save()
        @kugel.ctx.translate tail.x, tail.y
        @kugel.ctx.rotate @body.angle
        @kugel.ctx.scale @thrust * 3, @thrust * 3
        @kugel.ctx.drawImage @flame, -@flame.width/2, 0
        @kugel.ctx.restore()
                         
    pos: -> pos @body.position
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
        
        bullet = @kugel.physics.addBody 'bullet', @tip()
        bullet.setDensity 10
        bullet.restitution = 1
          
        bullet.setVelocity @dir().times(10).plus pos @body.velocity
        bullet.setAngle @body.angle

        @shootDelay = 100
        
        @bullets.push bullet

    smoke: ->
        
        if @puffs.length >= @maxPuffs
            @kugel.physics.delBody @puffs.shift()
        
        puff = @kugel.physics.addBody 'puff', @tip(-0.7-2*@thrust)

        puff.setMass 0.00000001
        puff.restitution = 0
        puff.maxScale = @thrust*64
        puff.lifespan = Math.max 4000, @thrust*2*6000
        puff.lifetime = puff.lifespan
        
        puff.tick = @onPuffTick
          
        puff.setVelocity @dir().times(-1-3*@thrust).plus pos @body.velocity

        @smokeDelay = 300 - Math.min(1, 2*@thrust) * 260
        
        @puffs.push puff
        
    onPuffTick: (delta) ->
        f        = 1 - @lifetime/@lifespan
        @scale   = @maxScale * (Math.log(f+0.2)+2)/2
        @opacity = 0.25 * @lifetime/@lifespan
        
module.exports = Ship
