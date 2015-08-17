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
deg2rad  = tools.deg2rad
rndrng   = tools.rndrng
rndint   = tools.rndint

class Snake
    
    constructor: (config) -> 
        @steps  = 10
        @index  = 0
        @tail   = []
        @ctrPos = config?.quat or Quat.rand()
        @angle  = rndint(360)-180
        @dir = 0
        @ctr = new THREE.Object3D()
        @obj = new THREE.Object3D()
        for i in [0..@steps-1]
            m = new Mesh
                type:   'sphere'
                material: material.snake
                detail: 1
                radius: 2.0-i/(@steps-1)
                position: new THREE.Vector3(0,6,0).applyQuaternion Quat.axis Mesh.X, -30-130*i/(@steps-1)
                parent: @obj   
        @ctr.add @obj
        scene.add @ctr
        
        @ctr.quaternion.copy @ctrPos
        @ctr.position.copy new THREE.Vector3(0,0,100).applyQuaternion(@ctrPos)
        
        if false
            new Mesh
                type:      'spike'
                radius:    1   
                color:     0xff0000
                position:  new THREE.Vector3 12,0,0
                parent:    @ctr
            
            new Mesh
                type:      'spike'
                radius:    1
                color:     0x008800
                position:  new THREE.Vector3 0,6,0
                parent:    @ctr
            
            new Mesh
                type:      'spike'
                radius:    1
                color:     0x0000ff
                position:  new THREE.Vector3 0,0,6
                parent:    @ctr
            
    frame: (step) =>
        
        # log "snake", step
        
        @obj.quaternion.copy Quat.axis Mesh.X, @angle

        @angle += 2
                
        if @angle >= 360
            @angle = 0
            rotangle = rndrng(-120, 120)
            @ctr.translateOnAxis(Mesh.Z, -100)
            @ctr.rotateOnAxis(Mesh.Z,  deg2rad(rotangle/2))
            @ctr.rotateOnAxis(Mesh.X,  deg2rad(10))
            @ctr.rotateOnAxis(Mesh.Z,  deg2rad(rotangle/2))
            @ctr.translateOnAxis(Mesh.Z,  100)
        
        # return
            
        if @angle > 160 and @angle % 20 == 0
            
            pos = new THREE.Vector3(0,-5.75,-1.5).applyQuaternion @obj.quaternion
            pos.applyQuaternion @ctr.quaternion
            pos.add @ctr.position
                    
            t = new Mesh
                type:      'box'
                radius:    1+Math.random()*0.5        
                color:     0x000044
                position:  pos
            t.quaternion.copy Quat.rand()
                
            @tail.unshift t
            
        for t in @tail
            t.position.setLength(t.position.length() - 0.04)
            
        if @tail.length > 0
            for i in [@tail.length-1..0]
                t = @tail[i]
                if t.position.length() < 98
                    @tail.splice(i, 1)[0].remove()
                
module.exports = Snake
