tools   = require './knix/tools'
color   = require './color'
clamp   = tools.clamp

###
00     00   0000000   000000000  00000000  00000000   000   0000000   000    
000   000  000   000     000     000       000   000  000  000   000  000    
000000000  000000000     000     0000000   0000000    000  000000000  000    
000 0 000  000   000     000     000       000   000  000  000   000  000    
000   000  000   000     000     00000000  000   000  000  000   000  0000000
###

material = 
    sphere: new THREE.MeshPhongMaterial
        color:              color.sphere
        side:               THREE.FrontSide
        shading:            THREE.SmoothShading
        shininess:          0
        
    spike: new THREE.MeshPhongMaterial
        color:              color.spike
        side:               THREE.FrontSide
        shading:            THREE.FlatShading
        shininess:          -5
              
    outline:   new THREE.ShaderMaterial 
        transparent: true,
        vertexShader: """
        varying vec3 vnormal;
        void main(){
            vnormal = normalize( mat3( modelViewMatrix[0].xyz, modelViewMatrix[1].xyz, modelViewMatrix[2].xyz ) * normal );
            gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
        }
        """
        fragmentShader: """
        varying vec3 vnormal;
        void main(){
            float z = abs(vnormal.z);
            gl_FragColor = vec4( 1,1,1, (1.0-z)*(1.0-z)/2.0 );
        }
        """
###
00     00  00000000   0000000  000   000
000   000  000       000       000   000
000000000  0000000   0000000   000000000
000 0 000  000            000  000   000
000   000  00000000  0000000   000   000
###

class Mesh extends THREE.Mesh

    constructor: (config={}) ->
        
        @type     = config.type   or 'sphere'
        @radius   = config.radius or 1
        @detail   = config.detail or 4
        
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

    # 
    # addOutline: (selected) => new THREE.Mesh selected.geometry, material.outline
    # 

    # ###
    # 000000000  00000000  000   000  000000000
    #    000     000        000 000      000   
    #    000     0000000     00000       000   
    #    000     000        000 000      000   
    #    000     00000000  000   000     000   
    # ###
    # 
    # addText: (text) =>
    #     text = new Text
    #         text:     text
    #         bevel:    true
    #         scale:    0.01
    #         prt:      scene
    #         material: @material.text
    #         segments: 6

module.exports = Mesh
