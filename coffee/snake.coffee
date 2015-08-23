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
Bot      = require './bot'
vec      = Vect.new
deg2rad  = tools.deg2rad
rndrng   = tools.rndrng
rndint   = tools.rndint

class Snake extends Bot
    
    constructor: (config={}) -> 
        
        config.trail = {}
        config.height = 0

        super config    
        
        @quat = Quat.rand()
        
        t = rndint(3)
        @steps  = [10, 12, 16][t]
        @radius = [6,   9, 12][t]
        @speed  = [4,   2,  1][t]

        @angle  = rndint(360/4)*4
        @swapAngle = deg2rad(360*@radius*2/(Math.PI*200.0))
    
        @ctra = new THREE.Object3D()
        @obja = new THREE.Object3D()
        @ctrb = new THREE.Object3D()
        @objb = new THREE.Object3D()
        
        for i in [0..@steps-2]
            m = new Mesh
                type:   'sphere'
                material: material.snake
                detail: 1
                radius: 2.0-i/(@steps-1)
                position: vec(0,@radius,0).applyQuaternion Quat.axis Vect.X, -180*i/(@steps-1)
                parent: @obja  
                            
        @ctra.add @obja
        @ctrb.add @objb
        @.add @ctra 
        @.add @ctrb
        @mova = (@angle >= 180)

        @ctra.quaternion.copy @quat
        @ctra.position.copy vec(0,0,100).applyQuaternion @quat

        @ctrb.quaternion.copy @quat
        @ctrb.position.copy vec(0,0,100).applyQuaternion @quat
        
        @ctrb.translateOnAxis Vect.Z, -100
        @ctrb.rotateOnAxis Vect.X, (@mova and 1 or -1) * @swapAngle
        @ctrb.translateOnAxis Vect.Z, 100
                
        if @angle >= 180    
            for j in [0..parseInt((@angle-180) / (180 / (@steps-1)))]
                @objb.add @obja.children[0]
                                    
    frame: (step) =>
        
        @angle += @speed

        intAngle = parseInt @angle
        fullAngle = Math.abs(intAngle-@angle) < 0.1

        if fullAngle and intAngle%180 == 0
            if intAngle == 360
                @angle = 0
                intAngle = 0
            swap = (a,b,r,s) ->
                a.position.copy b.position
                a.quaternion.copy b.quaternion
                a.translateOnAxis Vect.Z, -100
                a.rotateOnAxis Vect.X, r
                a.rotateOnAxis Vect.Z, deg2rad s
                a.rotateOnAxis Vect.X, r
                a.translateOnAxis Vect.Z,  100
                
            if @mova
                swap @ctra, @ctrb, @swapAngle*0.5, rndrng(-60,60)
            else
                swap @ctrb, @ctra, @swapAngle*0.5, rndrng(-60,60)
            @mova = not @mova
        
        @obja.quaternion.copy Quat.axis Vect.X, @angle
        @objb.quaternion.copy Quat.axis Vect.X, -@angle
        @objb.quaternion.multiply Quat.axis Vect.Z, 180
        
        super step
            
        if fullAngle
            if intAngle % parseInt(180/(@steps-1)) == 0 
                if @angle < 180 and @objb.children.length
                    @obja.add @objb.children[0]
                else if @angle >= 180 
                    @objb.add @obja.children[0]
                
            if @trail?
                if @angle >= 180 and intAngle % 20 == 0            
                    pos = vec(0,-@radius, 0).applyQuaternion @obja.quaternion
                    pos.applyQuaternion @ctra.quaternion
                    pos.add @ctra.position
                    @trail.add pos
                            
module.exports = Snake
