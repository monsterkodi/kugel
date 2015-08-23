###
000   000  00000000  00000000   000   000
000  000   000       000   000  0000  000
0000000    0000000   0000000    000 0 000
000  000   000       000   000  000  0000
000   000  00000000  000   000  000   000
###

Mesh     = require './mesh'
Quat     = require './quat'
log      = require './knix/log'
def      = require './knix/def'
tools    = require './knix/tools'
material = require './material'
Bot      = require './bot'
Vect     = require './vect'
vec      = Vect.new
deg2rad  = tools.deg2rad
rndrng   = tools.rndrng
rndint   = tools.rndint

class Kern extends Bot
    
    constructor: (config={}) -> 

        super config
        
        @attachTo config.bot if config.bot?
        
        @krn = new Mesh
            type: 'pyramid'
            material: material.kern
            radius:   1
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
            @position.copy @bot.center  
            @krn.rotateOnAxis Vect.X, deg2rad(-2)        
                
module.exports = Kern
