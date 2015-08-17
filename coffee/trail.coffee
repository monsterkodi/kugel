###
000000000  00000000    0000000   000  000    
   000     000   000  000   000  000  000    
   000     0000000    000000000  000  000    
   000     000   000  000   000  000  000    
   000     000   000  000   000  000  0000000
###
log      = require './knix/log'
Mesh     = require './mesh'
Quat     = require './quat'
Vect     = require './vect'
vec      = Vect.new

class Trail
    
    constructor: (num=50) -> 
        @num = num
        @meshes = []
        for i in [0..num]
            @meshes.push new Mesh
                type:   'box'
                radius: 1+Math.random()*2
                color:  0x000044
                dist:   0
                quat:   Quat.rand()
        
    frame: (step) =>    
        
        s = 0.008
        for m in @meshes
            length = m.position.length() - s
            s += 2*s/@num
            if length < 100 - m.radius
                @meshes.push @meshes.splice(@meshes.indexOf(m), 1)[0]
            else
                m.position.setLength length    
            
    add: (quat) =>
        
        @meshes.unshift @meshes.pop()
        @meshes[0].position.copy vec(0,0,100).applyQuaternion quat
        @meshes[0].quaternion.copy Quat.rand()

module.exports = Trail
