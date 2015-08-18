###
 0000000  000   000   0000000   000   000  00000000
000       0000  000  000   000  000  000   000     
0000000   000 0 000  000000000  0000000    0000000 
     000  000  0000  000   000  000  000   000     
0000000   000   000  000   000  000   000  00000000
###

Mesh     = require './mesh'
Quat     = require './quat'
log      = require './knix/log'
tools    = require './knix/tools'
material = require './material'
Vect     = require './vect'
Trail    = require './trail'
vec      = Vect.new
deg2rad  = tools.deg2rad
rndrng   = tools.rndrng
rndint   = tools.rndint

class Snake
    
    constructor: (config) -> 
        
        @steps  = 10
        @index  = 0

        @ctrPos = config?.quat or Quat.rand()
        @angle  = 0 #rndint(360)-180

        @trail = new Trail 
            num:       7
            maxRadius: 1.5
            speed:     0.02
        
        @ctra = new THREE.Object3D()
        @obja = new THREE.Object3D()
        @ctrb = new THREE.Object3D()
        @objb = new THREE.Object3D()
        
        for i in [0..@steps-2]
            m = new Mesh
                type:   'sphere'
                material: material.snake
                detail: 1
                radius: 1.1-i/(@steps-1)
                position: vec(0,6,0).applyQuaternion Quat.axis Vect.X, -180*i/@steps
                parent: @obja  
                
        @ctra.add @obja
        @ctrb.add @objb
        scene.add @ctra
        scene.add @ctrb
        @mova = false

        @ctra.quaternion.copy @ctrPos
        @ctra.position.copy vec(0,0,100).applyQuaternion(@ctrPos)

        @ctrb.quaternion.copy @ctrPos
        @ctrb.position.copy vec(0,0,100).applyQuaternion(@ctrPos)
        
        @ctrb.translateOnAxis Vect.Y, 12
                        
        if true

            new Mesh
                type:      'spike'
                radius:    1   
                color:     0xffffff
                position:  vec 0,0,0
                parent:    @ctra

            new Mesh
                type:      'spike'
                radius:    1   
                color:     0xff0000
                position:  vec 6,0,0
                parent:    @ctra
            
            new Mesh
                type:      'spike'
                radius:    1
                color:     0x004400
                position:  vec 0,6,0
                parent:    @ctra
            
            new Mesh
                type:      'spike'
                radius:    1
                color:     0x0000ff
                position:  vec 0,0,6
                parent:    @ctra

            new Mesh
                type:      'spike'
                radius:    1   
                color:     0x888888
                position:  vec 0,0,0
                parent:    @ctrb
                wireframe: true

            new Mesh
                type:      'spike'
                radius:    1   
                color:     0xff0000
                position:  vec 6,0,0
                parent:    @ctrb
                wireframe: true
            
            new Mesh
                type:      'spike'
                radius:    1
                color:     0x004400
                position:  vec 0,6,0
                parent:    @ctrb
                wireframe: true
            
            new Mesh
                type:      'spike'
                radius:    1
                color:     0x0000ff
                position:  vec 0,0,6
                parent:    @ctrb
                wireframe: true
            
    frame: (step) =>

        @angle += 2

        intAngle = parseInt @angle
        fullAngle = Math.abs(intAngle-@angle) < 0.1
        log intAngle, @angle, intAngle - @angle

        if fullAngle and intAngle%180 == 0
            if intAngle == 360
                @angle = 0
            # rotangle = rndrng(-120, 120)
            if @mova
                @ctra.translateOnAxis Vect.Y, -24
            else
                @ctrb.translateOnAxis Vect.Y, -24
            @mova = not @mova
        
        @obja.quaternion.copy Quat.axis Vect.X, @angle
        @objb.quaternion.copy Quat.axis Vect.X, -@angle
        @objb.quaternion.multiply Quat.axis Vect.Z, 180
            
        @trail.frame step
        
        if fullAngle
            if intAngle % 20 == 0 
                if @angle < 180 and @objb.children.length
                    @obja.add @objb.children[0]
                else if @angle >= 180 
                    @objb.add @obja.children[0]
                
            if @angle >= 180 and intAngle%20 == 0            
                pos = vec(0,-5.75,-1.5).applyQuaternion @obja.quaternion
                pos.applyQuaternion @ctra.quaternion
                pos.add @ctra.position
                @trail.add pos
        
                
                
module.exports = Snake
