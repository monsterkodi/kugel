###
000000000  00000000    0000000   000  000    
   000     000   000  000   000  000  000    
   000     0000000    000000000  000  000    
   000     000   000  000   000  000  000    
   000     000   000  000   000  000  0000000
###
Mesh     = require './mesh'
Quat     = require './quat'
log      = require './knix/log'
Vect     = require './vect'
vec      = Vect.new

class Trail
    
    constructor: () -> @meshes = []
        
    frame: (step) =>    

        for m in @meshes
            m.dist = m.dist-0.008
            m.position.copy vec(0,0,m.dist).applyQuaternion m.quat
            if m.dist < 97.5
                @meshes.splice(@meshes.indexOf(m), 1)[0].remove()
            
    add: (quat) =>
        @meshes.unshift new Mesh
            type:   'box'
            radius: 1+Math.random()*2
            color:  0x000044
            dist:   100
            quat:   quat
        @meshes[0].quaternion.copy Quat.rand()

module.exports = Trail
