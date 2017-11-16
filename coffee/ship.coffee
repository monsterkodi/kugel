
#  0000000  000   000  000  00000000 
# 000       000   000  000  000   000
# 0000000   000000000  000  00000000 
#      000  000   000  000  000      
# 0000000   000   000  000  000      

{ deg2rad, rad2deg, elem, fade, first, pos, sw, sh, log, _ } = require 'kxk'

{ fadeAngles } = require './utils'

intersect = require './intersect'
Matter    = require 'matter-js'

class Ship

    constructor: (@kugel) ->

        @thrust     = 0
        @angle      = 0
        @shoots     = false
        @lasers     = false
        @brakes     = false
        @shootDelay = 0
        @bullets    = []
        @maxBullets = 20
        @steerDir   = pos 0,0
        @rot        = left:0, right:0
        
        @body = @kugel.physics.addBody 'ship', x:sw()/2, y:sh()/2
        @body.collisionFilter.category = 2
        @body.collisionFilter.mask     = 3

        @body.item.style
            'stroke': '#fff'
            'stroke-width': 4
            
    # 000000000  000   0000000  000   000  
    #    000     000  000       000  000   
    #    000     000  000       0000000    
    #    000     000  000       000  000   
    #    000     000   0000000  000   000  
    
    onTick: (delta) ->

        @angle = rad2deg @body.angle
                
        length = @steerDir.length()
        if length - 0.1 > 0
            @angle  = fadeAngles @angle, @steerDir.rotation(pos 0,-1), length/10
            @thrust = length - 0.5
        else
            @thrust = 0
        
        if @brakes
            @thrust = 0
            @body.setVelocity pos(@body.velocity).times 0.99
                    
        @body.applyForce @dir().times @thrust / 10

        rotLeft  = @rot.left  * (@brakes and 0.1 or 1)
        rotRight = @rot.right * (@brakes and 0.1 or 1)
        
        @angle += rotRight - rotLeft
            
        @body.setAngle deg2rad @angle
        
        if @shootDelay > 0 then @shootDelay -= delta
        if @shoots and @shootDelay <= 0
            @shoot()
            
        if @lasers
            if not @beam
                @beam = @kugel.svg.line()
                @beam.style 'stroke-width': 1, 'stroke': '#88f', 'stroke-opacity': 0.5
            tip = @tip()
            tgt = tip.plus @pos().to(tip).scale 10000
            hits = Matter.Query.ray @kugel.physics.bodies, tip, tgt
            if hits.length
                hit = first hits
                tgt = intersect.rayBody tip, tgt, hit.bodyA
            @beam.plot tip.x, tip.y, tgt.x, tgt.y
        else
            if @beam
                @beam.remove()
                delete @beam

    steer: (@steerDir) ->
        
    turn: (leftOrRight, active) -> @rot[leftOrRight] = active and 1 or 0
        
    fire:  (@shoots) -> if not @shoots then @shootDelay = 0
    brake: (@brakes) ->         
    toggleLaser: -> @lasers = not @lasers
     
    pos: -> pos @body.position
    dir: -> pos(0,-1).rotate rad2deg @body.angle
    tip: (scale=1) -> @dir().scale(30*scale).plus @pos()
        
    #  0000000  000   000   0000000    0000000   000000000  
    # 000       000   000  000   000  000   000     000     
    # 0000000   000000000  000   000  000   000     000     
    #      000  000   000  000   000  000   000     000     
    # 0000000   000   000   0000000    0000000      000     
    
    shoot: ->
        
        if @bullets.length < @maxBullets
            bullet = @kugel.physics.addBody 'bullet', @tip()
            bullet.item.id "bullet#{@bullets.length}"
            bullet.setDensity 10
        else
            bullet = @bullets.shift()
            bullet.setPosition @tip()
            bullet.setAnglularVelocity 0
          
        bullet.setVelocity @dir().times 10
        bullet.setAngle @body.angle
        @shootDelay = 250
        
        @bullets.push bullet
        
module.exports = Ship
