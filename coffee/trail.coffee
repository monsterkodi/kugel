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
            length = m.position.length() - 0.008
            if length < 100 - m.radius
                @meshes.splice(@meshes.indexOf(m), 1)[0].remove()
            else
                m.position.setLength length    
            
    add: (quat) =>
        @meshes.unshift new Mesh
            type:   'box'
            radius: 1+Math.random()*2
            color:  0x000044
            dist:   100
            quat:   quat
        @meshes[0].quaternion.copy Quat.rand()

module.exports = Trail
