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
        @angle  = rndint(360)-180

        @trail = new Trail 
            num:       7
            maxRadius: 1.5
            speed:     0.02
        
        @ctra = new THREE.Object3D()
        @obja = new THREE.Object3D()
        @ctrb = new THREE.Object3D()
        @objb = new THREE.Object3D()
        for i in [0..@steps-1]
            m = new Mesh
                type:   'sphere'
                material: material.snake
                detail: 1
                radius: 2.0-i/(@steps-1)
                position: vec(0,6,0).applyQuaternion Quat.axis Vect.X, -180*i/@steps
                parent: @obja  
        @ctra.add @obja
        @ctrb.add @objb
        
        @ctrb.position.copy vec(0,0,100).applyQuaternion(@ctrPos)
        @ctrb.translateOnAxis Vect.Z, 12
        @ctrb.position.setLength 100
        @ctrb.quaternion Quat.vects vec(0,0,100), @ctrb.position
        
        scene.add @ctra
        scene.add @ctrb
        
        @ctra.quaternion.copy @ctrPos
        @ctra.position.copy vec(0,0,100).applyQuaternion(@ctrPos)
        
        if false
            new Mesh
                type:      'spike'
                radius:    1   
                color:     0xff0000
                position:  vec 12,0,0
                parent:    @ctr
            
            new Mesh
                type:      'spike'
                radius:    1
                color:     0x008800
                position:  vec 0,6,0
                parent:    @ctr
            
            new Mesh
                type:      'spike'
                radius:    1
                color:     0x0000ff
                position:  vec 0,0,6
                parent:    @ctr
            
    frame: (step) =>
        
        @obj.quaternion.copy Quat.axis Vect.X, @angle
        @blw.quaternion.copy Quat.axis Vect.X, -@angle
        @blw.quaternion.multiply Quat.axis Vect.Z, 180

        @angle += 1
                
        if @angle >= 360
            @angle = 0
            # rotangle = rndrng(-120, 120)
            # @ctr.translateOnAxis(Vect.Z, -100)
            # @ctr.rotateOnAxis(Vect.Z,  deg2rad(rotangle/2))
            # @ctr.rotateOnAxis(Vect.X,  deg2rad(10))
            # @ctr.rotateOnAxis(Vect.Z,  deg2rad(rotangle/2))
            # @ctr.translateOnAxis(Vect.Z,  100)
            pos = @blw.localToWorld vec()
            pos.setLength 100
            @ctr.position.copy pos
        
        @trail.frame step
        
        if @angle % 18 == 0
            if @angle < 180 and @blw.children.length
                @obj.add @blw.children[0]
                
            else if @angle >= 180 
                @blw.add @obj.children[0]
            
        if @angle >= 180 and @angle %20 == 0            
            pos = vec(0,-5.75,-1.5).applyQuaternion @obj.quaternion
            pos.applyQuaternion @ctr.quaternion
            pos.add @ctr.position
            @trail.add pos
            
                
                
module.exports = Snake
