
#  0000000  000   000  000  00000000 
# 000       000   000  000  000   000
# 0000000   000000000  000  00000000 
#      000  000   000  000  000      
# 0000000   000   000  000  000      

{ elem, first, pos, sw, sh, log, _ } = require 'kxk'

svg = require './svg'

class Ship

    constructor: (@kugel) ->

        @angle      = 0
        @thrust     = 0
        @shoots     = false
        @shootDelay = 0
        
        @ship = svg.add 'ship', parent:@kugel.svg

        @ship.style
            'stroke': '#fff'
            'stroke-width': 4
        
        @body = @kugel.physics.addItem @ship, x:sw()/2, y:sh()/2
        @body.collisionFilter.group    = 1
        @body.collisionFilter.category = 1
        @body.collisionFilter.mask     = 5
                
    onTick: (event) ->

        dir = pos(0,-1).rotate @body.angle*180.0/Math.PI
        @body.applyForce dir.times @thrust * 200
        @body.addAngle @angle/10
        
        if @shoots
            @shoot()

    fire: (@shoots) -> 0
        
    shoot: ->
        
        @shootDelay--
        if @shootDelay <= 0
            bullet = svg.add 'bullet', parent:@kugel.svg
            obj = @kugel.physics.addItem bullet, @body.position
            obj.collisionFilter.group    = 2
            obj.collisionFilter.category = 2
            obj.collisionFilter.mask     = 6
            dir = pos(0,-10).rotate @body.angle*180.0/Math.PI
            obj.setVelocity dir
            obj.setAngle @body.angle
            @shootDelay = 15
        
module.exports = Ship
