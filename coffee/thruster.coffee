
# 000000000  000   000  00000000   000   000   0000000  000000000  00000000  00000000 
#    000     000   000  000   000  000   000  000          000     000       000   000
#    000     000000000  0000000    000   000  0000000      000     0000000   0000000  
#    000     000   000  000   000  000   000       000     000     000       000   000
#    000     000   000  000   000   0000000   0000000      000     00000000  000   000

{ deg2rad, rad2deg, pos, _ } = require 'kxk'

svg = require './svg'

class Thruster

    constructor: (@physics, @body, @position, @direction) ->
        
        @puffs     = []
        @maxPuffs  = 100
        @puffDelay = 0
        @thrust    = 0
        @flame     = svg.image 'flame'

    del: ->
        
    draw: (ctx) ->
        
        ctx.save()
        ctx.translate @position.x, @position.y
        ctx.rotate deg2rad @direction.rotation pos 0,1
        ctx.scale @thrust, @thrust
        ctx.drawImage @flame, -@flame.width/2, 0
        ctx.restore()
        
    afterTick: (delta) ->

        if @puffDelay > 0 then @puffDelay -= delta
        if @puffDelay <= 0 and @thrust
            p = pos(@body.position).plus @position.copy().rotate rad2deg @body.angle
            d = @direction.copy().rotate rad2deg @body.angle
            puff = @addPuff p, d, @thrust
            @puffDelay = 300 - @thrust * 260

    addPuff: (position, direction, thrust) ->

        if @puffs.length >= @maxPuffs
            @physics.delBody @puffs.shift()
        
        x = position.x+2*direction.x
        y = position.y+2*direction.y
        puff = @physics.newBody 'puff', x:x, y:y

        puff.compOp = 'lighter'
        puff.collisionFilter.category = 8
        puff.collisionFilter.mask     = 10
        
        puff.setDensity 0.0000001
        puff.restitution = 0
        
        puff.maxScale = thrust * 16 * _.random 0.5, 1, true
        puff.lifespan = Math.max 2000, thrust*3000
        puff.lifetime = puff.lifespan
        
        puff.tick = @onPuffTick
        
        puff.setVelocity direction.times(1+@thrust).plus pos @body.velocity
        
        @puffs.push puff
        puff

    onPuffTick: (delta) ->
        f        = 1 - @lifetime/@lifespan
        @scale   = @maxScale * (Math.log(f+0.2)+2)/2
        @opacity = 0.25 * @lifetime/@lifespan
        
module.exports = Thruster
