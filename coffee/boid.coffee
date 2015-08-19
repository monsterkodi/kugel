###
0000000     0000000   000  0000000  
000   000  000   000  000  000   000
0000000    000   000  000  000   000
000   000  000   000  000  000   000
0000000     0000000   000  0000000  
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
fade     = tools.fade

class Boid extends Bot
    
    constructor: (config={}) -> 
        
        t = rndint(3)        
        
        config.height = [110, 120, 130][t]        
        config.trail  = 
            speed: -0.001
            num:   10
        
        super config

        @angle       = rndrng 0, 360
        @speed       = [4,  2,  1][t]
        @radius      = [2,  3,  4][t]
        @steer       = 0
        @steerTarget = 0
        @steerChange = [30, 60, 120][t]
        @steerKeep   = @steerChange*(1+rndint(2))
        @steerDeg    = [40, 30, 20][t]
        @steerSpeed  = [4, 3, 2][t]
        
        @obja = new THREE.Object3D()
        
        m = new Mesh
            type:     'torus'
            material: material.boid
            detail:   32
            radius:   @radius
            position: vec()
            parent:   @obja  

        m = new Mesh
            type:     'sphere'
            material: material.boid
            detail:   1
            radius:   @radius/4
            position: vec(0,-@radius*1.25,0)
            parent:   @obja
                            
        @ctra.add @obja
                                        
    frame: (step) =>
        
        @steerKeep -= 1
        if @steerKeep <= 0
            @steerKeep = @steerChange*(1+rndint(2))
            @steerTarget = deg2rad rndrng -@steerDeg, @steerDeg
        
        @steer = fade @steer, @steerTarget, @steerSpeed * 0.01
        forward = @speed * 0.001
        turn  = @steer * @steerSpeed * 0.01
        @ctra.translateOnAxis Vect.Z, -@height
        @ctra.rotateOnAxis Vect.X, -forward
        @ctra.rotateOnAxis Vect.Z, turn
        @ctra.translateOnAxis Vect.Z,  @height
        
        if @trail?
            if parseInt(@steerKeep) % (10*(5-@speed)) == 0
                @trail.add @ctra.position.clone().add vec(0,-@radius*1.25,0).applyQuaternion @ctra.quaternion
        
        super step
                        
module.exports = Boid
