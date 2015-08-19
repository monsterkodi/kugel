###
 0000000    0000000   00     00  00000000
000        000   000  000   000  000     
000  0000  000000000  000000000  0000000 
000   000  000   000  000 0 000  000     
 0000000   000   000  000   000  00000000
###

Mesh     = require './mesh'
Trail    = require './trail'
Snake    = require './snake'
Boid     = require './boid'
log      = require './knix/log'
dbg      = require './knix/log'
tools    = require './knix/tools'
material = require './material'
Quat     = require './quat'
Vect     = require './vect'
vec      = Vect.new
deg2rad  = tools.deg2rad
rad2deg  = tools.rad2deg
rndrng   = tools.rndrng
deg      = tools.deg
    
class Game
    
    constructor: (truck,renderer) ->
        
        @truck = truck
        @tgt = new THREE.Vector2 0,0
        @player = new Mesh
            type:     'spike'
            radius:   4
            color:    0xffffff
            dist:     104
            position: vec(0,0,100)
        
        @doto = new Mesh
            type:   'sphere'
            radius: 2
            color:  0x000088
            
        @trail = new Trail
            randQuat: true
            
        @snakes = []
        for i in [0..10]
            @snakes.push new Snake()

        @boids = []
        for i in [0..20]
            @boids.push new Boid()
            
        @createRing()
            
    createRing: () =>
        
        geometry = new THREE.Geometry()
        
        particles = 6000
            
        sprite = THREE.ImageUtils.loadTexture "img/disc.png" 

        for i in [0..particles]
            r = rndrng(0,1)
            r = r * r
            v = vec 250 + r*100, 0, 0
            v.applyQuaternion Quat.axis Vect.Y, rndrng(-180,180)
            v.y += rndrng(0,10)
            geometry.vertices.push v
            geometry.colors.push new THREE.Color 0,0,rndrng(0.25,0.5)

        mat = new THREE.PointCloudMaterial 
            size:            5
            sizeAttenuation: true 
            map:             sprite 
            alphaTest:       0.5
            transparent:     true
            vertexColors:    THREE.VertexColors
            
        particles = new THREE.PointCloud geometry, mat
        
        scene.add particles           
            
    mouse: (pos) => @tgt = pos
        
    frame: (step) =>
        
        q = @player.getWorldQuaternion().clone()
        d = step.delta * 1.5
        q.multiply Quat.axis(Vect.X, -@tgt.y * d)
        q.multiply Quat.axis(Vect.Y,  @tgt.x * d)
        
        @doto.setQuat q
        
        for snake in @snakes
            snake.frame step
            
        for boid in @boids
            boid.frame step
            
        @trail.frame step
        if @trail.meshes.length == 0 or @player.position.distanceTo(@trail.meshes[0].position) > 5
            @trail.add @player.position.clone().setLength(100)
        
        f = step.dsecs * 4
        @player.setQuat @player.getWorldQuaternion().slerp(q,f)
        
        f = step.dsecs * 2
        @truck.setQuat @truck.camera.getWorldQuaternion().slerp(q,f)
        
module.exports = Game
