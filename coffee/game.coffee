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
            radius: 8
            color:  0x000088
            dist:   110
            
    mouse: (pos) => @tgt = pos
        
    frame: =>
        s = 1
        @player.setAzimAlti @player.azim + @tgt.x * s, @player.alti + @tgt.y * s
        f = 0.01
        @truck.setAzimAlti @truck.azim * (1.0-f) + f * @player.azim, @truck.alti * (1.0-f) - f * @player.alti

        p = new THREE.Vector3 @tgt.x*1000, @tgt.y*1000, 600
        p.applyMatrix4 @truck.camera.matrixWorld
        # log p
        p.setLength 100
        @dot.position.copy p
        
        azimAlti = p.azimAlti()
        dbg azimAlti
        
        @doto.setAzimAlti azimAlti[0], azimAlti[1]

module.exports = Game
