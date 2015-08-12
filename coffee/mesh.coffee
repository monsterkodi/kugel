tools    = require './knix/tools'
color    = require './color'
material = require './material'
log      = require './knix/log'
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
                
        switch @type
            when 'sphere'
                geom = new THREE.IcosahedronGeometry @radius, @detail
            when 'spike'
                geom = new THREE.OctahedronGeometry @radius
        
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
        scene.add @
        
        if config.dist?
            pos   = new THREE.Vector3 0,0,config.dist
            pitch = deg2rad -@alti
            yaw   = deg2rad  @azim
            pos.applyAxisAngle new THREE.Vector3(1,0,0), pitch
            pos.applyAxisAngle new THREE.Vector3(0,1,0), yaw
            @position.copy pos
            @rotation.copy new THREE.Euler pitch, yaw, 0, 'YXZ'
        else if config.position?
            @position.copy new THREE.Vector3 config.position[0], config.position[1], config.position[2]

module.exports = Mesh
