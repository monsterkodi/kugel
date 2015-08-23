###
000   000  00000000  00000000   000   000
000  000   000       000   000  0000  000
0000000    0000000   0000000    000 0 000
000  000   000       000   000  000  0000
000   000  00000000  000   000  000   000
###

Mesh     = require './mesh'
Quat     = require './quat'
Bot      = require './bot'
Vect     = require './vect'
tools    = require './knix/tools'
vec      = Vect.new
deg2rad  = tools.deg2rad
rndrng   = tools.rndrng
rndint   = tools.rndint

class Kern extends Bot
    
    constructor: (config={}) -> 

        super config
        
        @attachTo config.bot if config.bot?
        @lerpSpeed = rndrng 0.04, 0.1
        @krn = new Mesh
            type:     'pyramid'
            material: 'kern'
            radius:   2
            position: vec()
            parent:   @
            quat:     Quat.axis Vect.X, rndrng 0,360
                
    attachTo: (bot) =>
        @bot?.kern = null
        @bot = bot
        @height = @bot.height
        @bot.kern = @
                
    frame: (step) =>
        if @bot
            @quaternion.copy @bot.quat
            @position.lerp @bot.center, @lerpSpeed
            @krn.rotateOnAxis Vect.X, deg2rad(-2)        
                
module.exports = Kern
