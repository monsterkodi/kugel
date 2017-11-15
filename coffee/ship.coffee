
#  0000000  000   000  000  00000000 
# 000       000   000  000  000   000
# 0000000   000000000  000  00000000 
#      000  000   000  000  000      
# 0000000   000   000  000  000      

{ rad2deg, elem, first, pos, sw, sh, log, _ } = require 'kxk'

Matter = require 'matter-js'

class Ship

    constructor: (@kugel) ->

        @angle      = 0
        @thrust     = 0
        @shoots     = false
        @lasers     = false
        @shootDelay = 0
        @bullets    = []
        @maxBullets = 20
        
        @body = @kugel.physics.addBody 'ship', x:sw()/2, y:sh()/2
        @body.collisionFilter.category = 2
        @body.collisionFilter.mask     = 3

        @body.item.style
            'stroke': '#fff'
            'stroke-width': 4
                
    onTick: (delta) ->

        @body.applyForce @dir().times @thrust / 10
        @body.addAngle @angle/10
        
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
                log first(hits).depth
            @beam.plot tip.x, tip.y, tgt.x, tgt.y
        else
            if @beam
                @beam.remove()
                delete @beam

    fire:  (@shoots) -> if not @shoots then @shootDelay = 0
    laser: (@lasers) ->
     
    pos: -> pos @body.position.x, @body.position.y
    dir: -> pos(0,-1).rotate rad2deg @body.angle
    tip: (scale=1) -> @dir().scale(30*scale).plus @pos()
        
    shoot: ->
        
        if @bullets.length < @maxBullets
            bullet = @kugel.physics.addBody 'bullet', @tip(0.5)
            bullet.collisionFilter.category = 4
            bullet.collisionFilter.mask     = 7
            bullet.setDensity 10
        else
            bullet = @bullets.shift()
            bullet.setPosition @tip(0.5)
            bullet.setAnglularVelocity 0
          
        bullet.setVelocity @dir().times 10
        bullet.setAngle @body.angle
        @shootDelay = 250
        
        @bullets.push bullet
        
module.exports = Ship
