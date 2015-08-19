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
tools    = require './knix/tools'
material = require './material'
Trail    = require './trail'
Vect     = require './vect'
vec      = Vect.new
deg2rad  = tools.deg2rad
rndrng   = tools.rndrng
rndint   = tools.rndint

class Bot
    
    constructor: (config={}) -> 

        @height = config.height or 100
        @ctrPos = config.quat or Quat.rand()
        @ctra = new THREE.Object3D()
        @ctra.quaternion.copy @ctrPos
        @ctra.position.copy vec(0,0,@height).applyQuaternion(@ctrPos)

        scene.add @ctra

        if config.trail
            
            @trail = new Trail 
                num:       config.trailNum or 7
                minRadius: 0.5
                maxRadius: 1.0
                speed:     config.trailSpeed or 0.03
                randQuat:  true

        if config.gimbal

            new Mesh
                type:      'spike'
                radius:    1   
                color:     0xffffff
                position:  vec 0,0,0
                parent:    @ctra

            new Mesh
                type:      'spike'
                radius:    1   
                color:     0xff0000
                position:  vec 6,0,0
                parent:    @ctra
            
            new Mesh
                type:      'spike'
                radius:    1
                color:     0x004400
                position:  vec 0,6,0
                parent:    @ctra
            
            new Mesh
                type:      'spike'
                radius:    1
                color:     0x0000ff
                position:  vec 0,0,6
                parent:    @ctra
                
    frame: (step) =>
        
        @trail?.frame step
                
module.exports = Bot
