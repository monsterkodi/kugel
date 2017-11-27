
# 000   000  00000000  000   000  000   0000000  000      00000000
# 000   000  000       000   000  000  000       000      000     
#  000 000   0000000   000000000  000  000       000      0000000 
#    000     000       000   000  000  000       000      000     
#     0      00000000  000   000  000   0000000  0000000  00000000

{ rad2deg, deg2rad, pos, log, _ } = require 'kxk'

class Vehicle

    constructor: (@kugel) ->
        
        @physics   = @kugel.physics
        @pad       = @kugel.pad
        @rot       = left:0, right:0
        
        @steer     = pos 0,0
        @thrust    = 0
        
        @brakes    = false
        @boosts    = false
        
        @thrusters = {}

    del: ->
        @physics.delBody @body
        for key,thruster of @thrusters
            thruster.del()
        
    draw: (ctx) ->
        
        ctx.save()
        ctx.translate @body.position.x, @body.position.y
        ctx.rotate @body.angle
        for key,thruster of @thrusters
            thruster.draw ctx
        ctx.restore()
        
        return
        
        ctx.save()
        ctx.beginPath()
        ctx.strokeStyle = '#ff0'
        ctx.lineWidth = @physics.zoom
        ctx.moveTo @pos().x, @pos().y
        ctx.lineTo @pos().plus(@up().times 60).x, @pos().plus(@up().times 60).y
        ctx.stroke()
        ctx.restore()
        
        if @kugel.planet?
            v = @kugel.planet.center.to(@pos()).normal()
            ctx.save()
            ctx.beginPath()
            ctx.strokeStyle = '#00f'
            ctx.lineWidth = @physics.zoom
            ctx.moveTo @pos().x, @pos().y
            ctx.lineTo @pos().plus(v.times 80).x, @pos().plus(v.times 80).y
            ctx.stroke()
            ctx.restore()

        v = pos 0,-1
        ctx.save()
        ctx.beginPath()
        ctx.strokeStyle = '#0f0'
        ctx.lineWidth = @physics.zoom
        ctx.moveTo @pos().x, @pos().y
        ctx.lineTo @pos().plus(v.times 100).x, @pos().plus(v.times 100).y
        ctx.stroke()
        ctx.restore()

        v = pos 1,0
        ctx.save()
        ctx.beginPath()
        ctx.strokeStyle = '#f00'
        ctx.lineWidth = @physics.zoom
        ctx.moveTo @pos().x, @pos().y
        ctx.lineTo @pos().plus(v.times 100).x, @pos().plus(v.times 100).y
        ctx.stroke()
        ctx.restore()
        
    beforeTick: (delta) ->
        
        @steer  = pos @pad.axis('leftX'), @pad.axis('leftY')
        @thrust = @steer.length()
        
        @brakes = @pad.button('square').pressed or @pad.button('L2').pressed
        @rot.left  = @pad.button('L1').pressed and 2 or 0
        @rot.right = @pad.button('R1').pressed and 2 or 0
        
    afterTick: (delta) ->
        
        for key,thruster of @thrusters
            thruster.afterTick delta
        
    pos: -> pos @body.position
    up:  -> pos(0,-1).rotate rad2deg @body.angle
    
    setPos: (position) -> @body.setPosition position
    
    show: -> log "show #{@name}"; @physics.addBody @body
    # hide: -> @physics.delBody @body
    
module.exports = Vehicle
