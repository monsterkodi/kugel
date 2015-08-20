###
00000000   000       0000000   000   000  00000000  00000000 
000   000  000      000   000   000 000   000       000   000
00000000   000      000000000    00000    0000000   0000000  
000        000      000   000     000     000       000   000
000        0000000  000   000     000     00000000  000   000
###

Mesh     = require './mesh'
Bot      = require './bot'
Quat     = require './quat'
Vect     = require './vect'
material = require './material'
vec      = Vect.new

class Player extends Bot

    constructor: (config={}) ->
        
        # config.gimbal = true
        config.height = 104
        config.trail = 
            num:       50
            minRadius: 1
            maxRadius: 2
            speed:     0.008
        
        super config
        
        @ball = new Mesh
            type:     'sphere'
            radius:   4
            detail:   1
            parent:   @ctra
            material: material.player
            
        # Mesh.addGimbal @ball
            
        @dot = new Mesh
            type:     'sphere'
            radius:   1
            detail:   1
            material: material.player

        @top = new Mesh
            type:     'spike'
            radius:   10
            detail:   1
            material: material.player
            
        @rollAngle = 0
        @tgt = new THREE.Vector2 0,0

    frame: (step, camera) =>

        camdist = vec(0,1,0).unproject(camera).setZ(0).length()
        check = vec(0,2,0).unproject(camera).setZ(0).length()
        
        tpos = vec(0,0,100).applyQuaternion camera.quaternion.clone().multiply Quat.axis Vect.X, -70
        zoom = tpos.project(camera).setZ(0).length()
        log zoom, @tgt.length(), Math.min(1, @tgt.length()/zoom)

        q = @ctra.quaternion.clone()
        d = step.delta * 1.5
        tl = @tgt.length()
        q.multiply Quat.axis(Vect.X, -@tgt.y*tl * d)
        q.multiply Quat.axis(Vect.Y,  @tgt.x*tl * d)
        
        @dot.setQuatHeight q, 100

        f = step.dsecs * 4
        @ctra.setQuatHeight @ctra.quaternion.slerp(q,f), @height
        
        @ball.quaternion.copy @ctra.quaternion
        @ball.lookAt @ctra.worldToLocal @dot.position.clone()
        @ball.up.copy @ctra.worldToLocal @ctra.position.normalized()
        @ball.rotateOnAxis Vect.X, -@rollAngle
        @rollAngle += 0.003* @ctra.position.distanceTo @dot.position
                
        if @ctra.position.distanceTo(@trail.meshes[0].position) > 5
            @trail.add @ctra.position.clone().setLength(100)

        super step

module.exports = Player
