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
tools    = require './knix/tools'
material = require './material'
vec      = Vect.new
rad2deg  = tools.rad2deg

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
                        
        @dot = new Mesh
            type:     'sphere'
            radius:   1
            detail:   1
            material: material.player
            
        @rollAngle = 0
        @speed = 0

    raySphereIntersection: (rp, rd) =>

        cp = rp.clone().add vec().sub(rp).projectOnVector(rd)
        pl = cp.length()
        if pl > 100
            cp.setLength 100
        else
            d = cp.sub(rp).length() - Math.sqrt(10000 - pl*pl)
            rp.clone().add rd.clone().multiplyScalar(d)
        
    setTargetCamera: (tgt,camera) =>
                
        rd = vec(tgt.x, tgt.y, 1).unproject(camera).sub(camera.position).normalized()        
        @dot.position.copy @raySphereIntersection camera.position, rd
        
    frame: (step) =>
        
        q = Quat.vecs @ctra.position, @dot.position
        q.multiply @ctra.quaternion
        
        f = step.dsecs * 4
        @ctra.setQuatHeight @ctra.quaternion.slerp(q,f), @height
        
        @ball.quaternion.copy @ctra.quaternion
        @ball.lookAt @ctra.worldToLocal @dot.position.clone()
        @ball.up.copy @ctra.worldToLocal @ctra.position.normalized()
        @ball.rotateOnAxis Vect.X, -@rollAngle
        @rollAngle += 0.003* @ctra.position.distanceTo @dot.position
                
        if @trail?
            if @ctra.position.distanceTo(@trail.meshes[0].position) > 5
                @trail.add @ctra.position.clone().setLength(100)

        super step

module.exports = Player
