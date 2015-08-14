###
 0000000    0000000   00     00  00000000
000        000   000  000   000  000     
000  0000  000000000  000000000  0000000 
000   000  000   000  000 0 000  000     
 0000000   000   000  000   000  00000000
###

Mesh     = require './mesh'
log      = require './knix/log'
dbg      = require './knix/log'
tools    = require './knix/tools'
material = require './material'
deg2rad  = tools.deg2rad
rad2deg  = tools.rad2deg
deg      = tools.deg

VectorX = new THREE.Vector3 1,0,0
VectorY = new THREE.Vector3 0,1,0
VectorZ = new THREE.Vector3 0,0,1

quazimalti = (azim, alti) ->
    qaz = new THREE.Quaternion().setFromAxisAngle VectorY, deg2rad(azim)
    qal = new THREE.Quaternion().setFromAxisAngle VectorX, deg2rad(-alti)
    qaz.multiply qal

THREE.Vector3.prototype.normalized = () -> 
    v = new THREE.Vector3()
    v.copy @
    v.normalize()
    v
    
THREE.Vector3.prototype.azimAlti = () -> 
    
    p_y = new THREE.Vector3
    p_y.copy @
    p_y.projectOnPlane VectorY
    
    azim = rad2deg p_y.angleTo VectorZ
    if @dot(VectorX) < 0
        azim = -azim
        
    alti = rad2deg @angleTo p_y
    if @dot(VectorY) < 0
        alti = -alti
        
    [azim, alti]

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
            dist:   0 #106
            
        geometry = new THREE.Geometry()
        
        particles = 10000
        colors = []
            
        sprite = THREE.ImageUtils.loadTexture "img/disc.png" 

        for i in [0..particles]
            r = Math.random()
            r = r * r
            
            v = new THREE.Vector3 300 + r*100, 0, 0
            v.applyQuaternion new THREE.Quaternion().setFromAxisAngle VectorY, 2*Math.random()*Math.PI
            v.y += Math.random()*10
            geometry.vertices.push v
            colors.push new THREE.Color 0,0,0.25+Math.random()*0.25

        geometry.colors = colors
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

        p = new THREE.Vector3 @tgt.x*window.innerWidth, @tgt.y*window.innerHeight, 440
        p.applyMatrix4 @truck.camera.matrixWorld
        p.setLength 100
        
        [azim, alti] = p.azimAlti()
        q = quazimalti azim, alti
        
        @doto.setQuat q
        
        f = 0.04
        q2 = @player.getWorldQuaternion().slerp(q,f)
        @player.setQuat q2
        
        f = 0.01
        q3 = @truck.camera.getWorldQuaternion().slerp(q2,f)
        @truck.setQuat q3
        

module.exports = Game
