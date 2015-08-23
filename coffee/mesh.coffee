###
00     00  00000000   0000000  000   000
000   000  000       000       000   000
000000000  0000000   0000000   000000000
000 0 000  000            000  000   000
000   000  00000000  0000000   000   000
###

tools    = require './knix/tools'
color    = require './color'
material = require './material'
log      = require './knix/log'
Vect     = require './vect'
vec      = Vect.new
clamp    = tools.clamp
deg2rad  = tools.deg2rad

class Mesh extends THREE.Mesh

    constructor: (config={}) ->
        
        @type   = config.type   or 'sphere'
        @radius = config.radius or 1
        @detail = config.detail if config.detail?
        @dist   = config.dist   or 0
                
        switch @type
            when 'sphere'
                @detail = 4 unless @detail?
                geom = new THREE.IcosahedronGeometry @radius, @detail
            when 'spike'
                geom = new THREE.OctahedronGeometry @radius
            when 'ring'
                @detail = 16 unless @detail?
                geom = new THREE.RingGeometry @radius/2, @radius, @detail
            when 'torus'
                @detail = 32 unless @detail?
                geom = new THREE.TorusGeometry @radius, @radius/4, @detail, @detail/2
            when 'pyramid'
                geom = new THREE.TetrahedronGeometry @radius
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
            @material = material[config.material]? and material[config.material] or config.material? and config.material or material[@type]
        
        super geom, @material 
        
        if config.parent?
            config.parent.add @ 
        else 
            scene.add @
        
        if config.quat?
            @quat = config.quat
            @setQuatHeight config.quat, @dist
        else if config.position?
            @position.copy config.position
            
    remove: () => scene.remove @        

    @addGimbal: (prt) ->

            new Mesh
                type:      'spike'
                radius:    1   
                color:     0xffffff
                position:  vec 0,0,0
                parent:    prt

            new Mesh
                type:      'spike'
                radius:    1   
                color:     0xff0000
                position:  vec 6,0,0
                parent:    prt
            
            new Mesh
                type:      'spike'
                radius:    1
                color:     0x004400
                position:  vec 0,6,0
                parent:    prt
            
            new Mesh
                type:      'spike'
                radius:    1
                color:     0x0000ff
                position:  vec 0,0,6
                parent:    prt

module.exports = Mesh
