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
def      = require './knix/def'
tools    = require './knix/tools'
Note     = require './knix/note'
Keyboard = require './knix/keyboard'
sound    = require './sound'
play     = Note.play
vec      = Vect.new
deg2rad  = tools.deg2rad
rndrng   = tools.rndrng
rndint   = tools.rndint

class Kern extends Bot
    
    constructor: (config={}) -> 

        super config

        @note = Keyboard.noteNames[rndint(Keyboard.noteNames.length)]
        
        @attachTo config.bot if config.bot?
        
        @krn = new Mesh
            type:     'pyramid'
            material: 'kern'
            radius:   2
            position: vec()
            parent:   @
            quat:     Quat.axis Vect.X, rndrng 0,360
                
    attachTo: (bot) =>
        @target = null
        @bot?.kern = null
        @bot = bot
        note = 
            name: @note
        if @bot.isPlayer?
            play def note, sound.kernPlayer
            @lerpSpeed = rndrng 0.04, 0.3
            @bot.setKern @
        else if @bot.isTree?
            @lerpSpeed = 0.1
            @bot.setKern @
        else
            @lerpSpeed = 0.2
            @bot._kern = @
                
    frame: (step) =>
        if @target?
            @position.lerp @target, @lerpSpeed
            @krn.rotateOnAxis Vect.X, deg2rad -2            
        else if @bot
            @quaternion.copy @bot.quat
            @position.lerp @bot.center, @lerpSpeed
            @krn.rotateOnAxis Vect.X, deg2rad -2
            
            if not @bot.isPlayer? and not @bot.isTree?
                if @position.distanceToSquared(@bot.center) < 6
                    @bot.setKern @
                    @bot._kern = null
                    @lerpSpeed = 1
                
module.exports = Kern
