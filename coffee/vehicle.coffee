
# 000   000  00000000  000   000  000   0000000  000      00000000
# 000   000  000       000   000  000  000       000      000     
#  000 000   0000000   000000000  000  000       000      0000000 
#    000     000       000   000  000  000       000      000     
#     0      00000000  000   000  000   0000000  0000000  00000000

{ pos, log, _ } = require 'kxk'

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

    draw: (ctx) ->
        
        ctx.save()
        ctx.translate @body.position.x, @body.position.y
        ctx.rotate @body.angle
        for key,thruster of @thrusters
            thruster.draw ctx
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
    
    setPos: (position) -> @body.setPosition position
    
    show: -> @physics.addBody @body
    hide: -> @physics.delBody @body
    
module.exports = Vehicle
