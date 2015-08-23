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
        
        config.height = 102
        config.trail = 
            num:       50
            minRadius: 1
            maxRadius: 2
            speed:     0.008
        
        super config
        
        @ball = new Mesh
            type:     'sphere'
            radius:   2
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
        @boid = null
        @jumpHeight = 0
        @jumpTarget = 0
        @jumpTime = 0
        
        window.addEventListener 'mousedown',  @jump

    jump: () => 
        if @jumpTarget > 0
            @jumpTarget = 0
            @jumpTime = 0
        else
            if @boid
                @lastboid = @boid
                @boid = null
                @jumpTarget = @height - 100 + 20
            else
                @jumpTarget = 20
            @jumpTime = 0
            @jumpQuat = Quat.axis Vect.X.clone().applyQuaternion(@ball.quaternion), -rad2deg(@ctra.position.angleTo(@dot.position))*0.005

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
        
    attachTo: (boid) =>
        if @boid != boid and boid != @lastboid
            @boid = boid
            @jumpTarget = 0
            @jumpHeight = 0
            @height = boid.ctra.position.length()
        
    frame: (step) =>
        
        q = Quat.vecs @ctra.position, @dot.position
        q.multiply @ctra.quaternion
                
        if @jumpTarget > 0
            @jumpTime += step.dsecs * 4
            @jumpHeight = Math.sin(@jumpTime) * @jumpTarget
            if @jumpTime >= Math.PI*0.5 
                @lastboid = null
            if @jumpTime >= 3.3
                if @height > 102
                    @jumpHeight = @height - 102
                    @height = 102
                @jumpTarget = 0
                @jumpTime = 0
        else if @jumpHeight > 0
            @jumpHeight = fade @jumpHeight, 0, 0.2
        if @jumpHeight < 0
            @jumpHeight = fade @jumpHeight, 0, 0.04

        if @jumpTarget == 0
            f = step.dsecs
            if @height >= 129
                f *= 1.0
            else if @height >= 119
                f *= 0.5
            else if @height >= 109
                f *= 0.3
            else
                f *= 0.25

            @ctra.setQuatHeight @ctra.quaternion.slerp(q,f), @height
        else
            @ctra.setQuatHeight @ctra.quaternion.multiply(@jumpQuat), @height
        
        if @boid and @jumpTarget == 0
            @boid.ctra.position.copy @ctra.position
            ml = new THREE.Matrix4().lookAt(@ctra.position.clone().setLength(100), @dot.position, @ctra.position.normalized())
            @boid.ctra.quaternion.setFromRotationMatrix(ml)
            @boid.ctra.quaternion.multiply Quat.axis Vect.X, -90
        
        @ball.quaternion.copy @ctra.quaternion
        @ball.lookAt @ctra.worldToLocal @dot.position.clone()
        @ball.up.copy @ctra.worldToLocal @ctra.position.normalized()
        @ball.position.copy(@ball.up).setLength -@jumpHeight
        
        if @jumpHeight < 1 and not @boid?
            
            @ball.rotateOnAxis Vect.X, -@rollAngle
            @rollAngle += 0.009* @ctra.position.clone().setLength(100).distanceTo @dot.position
                
            if @trail?
                if @ctra.position.distanceTo(@trail.meshes[0].position) > 5
                    @trail.add @ctra.position.clone().setLength(100)

        super step

module.exports = Player
