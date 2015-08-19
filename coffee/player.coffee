###
00000000   000       0000000   000   000  00000000  00000000 
000   000  000      000   000   000 000   000       000   000
00000000   000      000000000    00000    0000000   0000000  
000        000      000   000     000     000       000   000
000        0000000  000   000     000     00000000  000   000
###

Mesh = require './mesh'
Bot  = require './bot'
Quat = require './quat'
Vect = require './vect'
vec  = Vect.new

class Player extends Bot

    constructor: (config={}) ->
    
        config.height = 104
        config.trail = 
            num:       50
            minRadius: 1
            maxRadius: 2
            speed:     0.008
        
        super config
        
        m = new Mesh
            type:   'spike'
            radius: 4
            color:  0xffffff
            parent: @ctra
            
        @tgt = new THREE.Vector2 0,0

    frame: (step) =>
        q = @ctra.getWorldQuaternion().clone()
        d = step.delta * 1.5
        q.multiply Quat.axis(Vect.X, -@tgt.y * d)
        q.multiply Quat.axis(Vect.Y,  @tgt.x * d)

        f = step.dsecs * 4
        @ctra.setQuat @ctra.getWorldQuaternion().slerp(q,f), @height
        
        if @ctra.position.distanceTo(@trail.meshes[0].position) > 5
            @trail.add @ctra.position.clone().setLength(100)

        super step

module.exports = Player
