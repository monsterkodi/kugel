tools   = require './knix/tools'
color   = require './color'
clamp   = tools.clamp

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
        
        switch @type
            when 'sphere'
                geom = new THREE.IcosahedronGeometry @radius, @detail
            when 'spike'
                geom = new THREE.OctahedronGeometry @radius
        
        @material = config.material or material[@type]
        super geom, @material 
        scene.add @
        
        if config.dist?
            @position.copy new THREE.Vector3 0, 0, config.dist

module.exports = Mesh
