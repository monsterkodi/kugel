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
log      = require './knix/log'
dbg      = require './knix/log'
tools    = require './knix/tools'
material = require './material'
deg2rad  = tools.deg2rad
rad2deg  = tools.rad2deg
deg      = tools.deg
Quat     = require './quat'

VectorX = new THREE.Vector3 1,0,0
VectorY = new THREE.Vector3 0,1,0
VectorZ = new THREE.Vector3 0,0,1

THREE.Vector3.prototype.normalized = () -> 
    v = new THREE.Vector3()
    v.copy @
    v.normalize()
    v
    
class Game
    
    constructor: (truck,renderer) ->
        @truck = truck
        @tgt = new THREE.Vector2 0,0
        @player = new Mesh
            type:   'spike'
            radius: 4
            color:  0xffffff
            dist:   104
            azim:   0
        
        @doto = new Mesh
            type:   'sphere'
            radius: 2
            color:  0x000088
            dist:   108
            
        @trail = new Trail()
        @snakes = []
        for i in [0..0]
            @snakes.push new Snake
                quat: Quat.rand()
                angle: Math.random()*180
            
        @createRing()
            
    createRing: () =>
        geometry = new THREE.Geometry()
        
        particles = 6000
            
        sprite = THREE.ImageUtils.loadTexture "img/disc.png" 

        for i in [0..particles]
            r = Math.random()
            r = r * r
            v = new THREE.Vector3 200 + r*100, 0, 0
            v.applyQuaternion new THREE.Quaternion().setFromAxisAngle VectorY, 2*Math.random()*Math.PI
            v.y += Math.random()*10
            geometry.vertices.push v
            geometry.colors.push new THREE.Color 0,0,0.25+Math.random()*0.25

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
        
    frame: =>
        
        q = @player.getWorldQuaternion().clone()
        q.multiply new THREE.Quaternion().setFromAxisAngle(VectorX, -@tgt.y*0.3)
        q.multiply new THREE.Quaternion().setFromAxisAngle(VectorY,  @tgt.x*0.3)
        
        @doto.setQuat q
        for snake in @snakes
            snake.frame()
        @trail.frame()
        if @trail.meshes.length == 0 or @player.position.distanceTo(@trail.meshes[0].position) > 5
            @trail.add @player.getWorldQuaternion()
        
        f = 0.04
        q2 = @player.getWorldQuaternion().slerp(q,f)
        @player.setQuat q2
        
        f = 0.02
        q3 = @truck.camera.getWorldQuaternion().slerp(q,f)
        @truck.setQuat q3
        
module.exports = Game
