tools    = require './knix/tools'
color    = require './color'
material = require './material'
log      = require './knix/log'
Vect     = require './vect'
vec      = Vect.new
clamp    = tools.clamp
deg2rad  = tools.deg2rad

###
00     00  00000000   0000000  000   000
000   000  000       000       000   000
000000000  0000000   0000000   000000000
000 0 000  000            000  000   000
000   000  00000000  0000000   000   000
###

class Mesh extends THREE.Mesh

    constructor: (config={}) ->
        
        @type   = config.type   or 'sphere'
        @radius = config.radius or 1
        @detail = config.detail or 4
        @alti   = config.alti   or 0
        @azim   = config.azim   or 0
        @dist   = config.dist   or 0
                
        switch @type
            when 'sphere'
                geom = new THREE.IcosahedronGeometry @radius, @detail
            when 'spike'
                geom = new THREE.OctahedronGeometry @radius
            when 'box'
                geom = new THREE.BoxGeometry @radius, @radius, @radius
        
        if config.color?
            @material = new THREE.MeshLambertMaterial
                color:     config.color
                side:      THREE.FrontSide
                shading:   THREE.FlatShading
                wireframe: config.wireframe or false
                wireframeLinewidth: 2
                shininess: 0
        else
            @material = config.material or material[@type]
        
        super geom, @material 
        
        if config.parent?
            config.parent.add @ 
        else 
            scene.add @
        
        if config.quat?
            @quat = config.quat
            @setQuat config.quat
        else if config.dist?
            @setAzimAlti @azim, @alti
        else if config.position?
            @position.copy config.position
            
    remove: () => scene.remove @
            
    setAzimAlti: (azim,alti) =>
        @alti = alti
        @azim = azim
        pos   = vec 0,0,@dist
        pitch = deg2rad -@alti
        yaw   = deg2rad  @azim
        pos.applyAxisAngle vec(1,0,0), pitch
        pos.applyAxisAngle vec(0,1,0), yaw
        @position.copy pos
        @rotation.copy new THREE.Euler pitch, yaw, 0, 'YXZ'
        
    setQuat: (quat) =>
        @quaternion.copy quat
        @position.copy vec(0,0,@dist).applyQuaternion quat
        

module.exports = Mesh
