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
Line     = require './line'
tools    = require './knix/tools'
material = require './material'
vec      = Vect.new
rad2deg  = tools.rad2deg

class Player extends Bot

    constructor: (config={}) ->
        
        config.gimbal = true
        
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

        @top = new Mesh
            type:     'spike'
            radius:   6
            detail:   1
            material: material.player
            
        @rollAngle = 0
        @tgt = new THREE.Vector2 0,0
        @speed = 0
        @line = []
        
        @line[0] = new Line
            color: 0xff0000
            from: vec()
            to: vec(200,0,0)

        @line[1] = new Line
            color: 0x006600
            from: vec()
            to: vec(0,200,0)

        @line[2] = new Line
            color: 0x0000ff
            from: vec()
            to: vec(0,0,200)


    raySphereIntersection: (rp, rd) =>

        cp = rp.clone().add vec().sub(rp).projectOnVector(rd)
        pl = cp.length()
        if pl > 100
            cp.setLength(100)
            return cp
        
        d = cp.sub(rp).length() - Math.sqrt(10000 - pl*pl)
        p = rp.clone().add rd.clone().multiplyScalar(d)
        
    setTargetCamera: (tgt,camera) =>
        
        # north = vec(0,100,100)
        # north.applyQuaternion Quat.axis Vect.X, 20 
        # north.applyQuaternion camera.quaternion
        # zoom = north.project(camera).setZ(0).length()
        
        @top.position.copy vec(0,0,-100)
                
        @tgt = tgt.normalized()

        rd = vec(tgt.x, tgt.y, 1).unproject(camera).sub(camera.position).normalized()
        p1 = @raySphereIntersection camera.position, rd
        
        @dot.position.copy p1
        
        # for l in @line
        #     l.remove()
        #     
        # @line[0] = new Line
        #     from: vec()
        #     to: p1

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
