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
fade     = tools.fade

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
        @jumpHeight = 0
        @jumpTarget = 0
        @jumpTime = 0
        
        window.addEventListener 'mousedown',  @jump

    jump: () => 
        @jumpTarget = 40
        @jumpTime = 0
        @jumpQuat = Quat.axis Vect.X.clone().applyQuaternion(@ball.quaternion), -rad2deg(@ctra.position.angleTo(@dot.position))*0.02

    setTargetCamera: (mouse,camera,planet) =>

        rd = vec(mouse.x, mouse.y, 1).unproject(camera).sub(camera.position).normalize()
        cp = camera.position.clone().add vec().sub(camera.position).projectOnVector(rd)
        pl = cp.length()
        if pl > 100
            cp.setLength 100
        else
            d = cp.sub(camera.position).length() - Math.sqrt(10000 - pl*pl)
            cp = camera.position.clone().add rd.multiplyScalar(d)
                        
        @dot.position.copy cp
        
    frame: (step) =>
        
        q = Quat.vecs @ctra.position, @dot.position
        q.multiply @ctra.quaternion
                
        if @jumpTarget > 0
            @jumpTime += step.dsecs * 2
            @jumpHeight = Math.sin(@jumpTime) * @jumpTarget
            if @jumpTime >= 3.3
                @jumpTarget = 0
                @jumpTime = 0
        if @jumpHeight < 0
            @jumpHeight = fade @jumpHeight, 0, 0.04

        if @jumpTarget == 0
            f = step.dsecs * 1.5
            @ctra.setQuatHeight @ctra.quaternion.slerp(q,f), @height
        else
            @ctra.setQuatHeight @ctra.quaternion.multiply(@jumpQuat), @height
        
        @ball.quaternion.copy @ctra.quaternion
        @ball.lookAt @ctra.worldToLocal @dot.position.clone()
        @ball.up.copy @ctra.worldToLocal @ctra.position.normalized()
        @ball.position.copy(@ball.up).setLength -@jumpHeight
        
        if @jumpTarget == 0
            @ball.rotateOnAxis Vect.X, -@rollAngle
            @rollAngle += 0.009* @ctra.position.clone().setLength(100).distanceTo @dot.position
                
            if @trail?
                if @ctra.position.distanceTo(@trail.meshes[0].position) > 5
                    @trail.add @ctra.position.clone().setLength(100)

        super step

module.exports = Player
