###
000000000  00000000    0000000   000  000    
   000     000   000  000   000  000  000    
   000     0000000    000000000  000  000    
   000     000   000  000   000  000  000    
   000     000   000  000   000  000  0000000
###

log      = require './knix/log'
tools    = require './knix/tools'
Mesh     = require './mesh'
Quat     = require './quat'
Vect     = require './vect'
vec      = Vect.new
rndrng   = tools.rndrng

class Trail
    
    constructor: (config={}) -> 
        @num       = config.num or 50
        @minRadius = config.minRadius or 1
        @maxRadius = config.maxRadius or 2
        @speed     = config.speed or 0.008
        @meshes    = []
        for i in [0..@num]
            m = new Mesh
                type:     'box'
                material: 'trail'
                radius:   rndrng @minRadius, @maxRadius
                quat:     config.randQuat and Quat.rand() or new Quat()
                dist:     0
            @meshes.push m
        
    frame: (step) =>    
        
        s = @speed
        for m in @meshes
            l = m.length
            if l < 100 - m.radius
                break
            m.length = l - s
            s += 2*s/@num
            if m.length < 100 - m.radius
                @meshes.push @meshes.splice(@meshes.indexOf(m), 1)[0]
            else
                m.position.setLength m.length    
            
    add: (pos) =>
        
        @meshes.unshift @meshes.pop()
        @meshes[0].length = pos.length()
        @meshes[0].position.copy pos

module.exports = Trail
