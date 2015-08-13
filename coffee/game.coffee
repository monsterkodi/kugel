###
 0000000    0000000   00     00  00000000
000        000   000  000   000  000     
000  0000  000000000  000000000  0000000 
000   000  000   000  000 0 000  000     
 0000000   000   000  000   000  00000000
###

Mesh    = require './mesh'
log     = require './knix/log'
dbg     = require './knix/log'
tools   = require './knix/tools'
deg2rad = tools.deg2rad
rad2deg = tools.rad2deg
deg     = tools.deg

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
    
    constructor: (truck) ->
        @truck = truck
        @tgt = new THREE.Vector2 0,0
        @player = new Mesh
            type:   'spike'
            radius: 10
            color:  0xffffff
            dist:   110
            azim:   0
            
        @dot = new Mesh
            type:   'sphere'
            radius: 10
            color:  0x888888
            position: [0,0,0]

        @doto = new Mesh
            type:   'sphere'
            radius: 2
            color:  0x000088
            dist:   120
            
    mouse: (pos) => @tgt = pos
        
    frame: =>

        p = new THREE.Vector3 @tgt.x*1000, @tgt.y*1000, 600
        p.applyMatrix4 @truck.camera.matrixWorld
        p.setLength 100
        @dot.position.copy p
        
        [azim, alti] = p.azimAlti()
        q = quazimalti azim, alti
        
        @doto.setQuat q
        
        f = 0.04
        q2 = @player.getWorldQuaternion().slerp(q,f)
        @player.setQuat q2
        
        f = 0.05
        q3 = @truck.camera.getWorldQuaternion().slerp(q2,f)
        @truck.setQuat q3
        

module.exports = Game
