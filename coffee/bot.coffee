###
0000000     0000000   000000000
000   000  000   000     000   
0000000    000   000     000   
000   000  000   000     000   
0000000     0000000      000   
###

Mesh     = require './mesh'
Quat     = require './quat'
log      = require './knix/log'
def      = require './knix/def'
tools    = require './knix/tools'
material = require './material'
Trail    = require './trail'
Vect     = require './vect'
vec      = Vect.new
deg2rad  = tools.deg2rad
rndrng   = tools.rndrng
rndint   = tools.rndint

class Bot extends THREE.Object3D
    
    constructor: (config={}) -> 

        @height = config.height or 100
        @ctrPos = config.quat or Quat.rand()
        super
        
        @quaternion.copy @ctrPos
        @position.copy vec(0,0,@height).applyQuaternion(@ctrPos)

        scene.add @

        if config.trail #and false
            
            @trail = new Trail def config.trail,
                num:       7
                minRadius: 0.5
                maxRadius: 1.0
                speed:     0.03
                randQuat:  true

        if config.gimbal
            
            Mesh.addGimbal @
                
    frame: (step) =>
        
        @trail?.frame step
                
module.exports = Bot
