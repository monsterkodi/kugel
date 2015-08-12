tools   = require './knix/tools'
clamp   = tools.clamp

###
00     00   0000000   000000000  00000000  00000000   000   0000000   000    
000   000  000   000     000     000       000   000  000  000   000  000    
000000000  000000000     000     0000000   0000000    000  000000000  000    
000 0 000  000   000     000     000       000   000  000  000   000  000    
000   000  000   000     000     00000000  000   000  000  000   000  0000000
###

color = 
    sphere:        0x333333
    spike:         0x4444ff
    selected:      0xffffff

material = 
    sphere: new THREE.MeshPhongMaterial
        color:              color.sphere
        side:               THREE.FrontSide
        shading:            THREE.FlatShading
        # shading:            THREE.SmoothShading
        transparent:        false
        shininess:          0
        # wireframe:          true
        depthTest:          true
        depthWrite:         true
        opacity:            0.2
        wireframeLinewidth: 2
        
    spike: new THREE.MeshPhongMaterial
        color:              color.spike
        side:               THREE.FrontSide
        shading:            THREE.FlatShading
        transparent:        true
        shininess:          -5
        wireframe:          false
        depthTest:          false
        depthWrite:         false
        opacity:            0.2
        wireframeLinewidth: 2
      
    text: new THREE.MeshPhongMaterial 
        color:       0x8888ff
        shading:     THREE.FlatShading
        transparent: true
        opacity:     1.0
        
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
0000000     0000000   000      000       0000000
000   000  000   000  000      000      000     
0000000    000000000  000      000      0000000 
000   000  000   000  000      000           000
0000000    000   000  0000000  000000x0  0000000 
###

class Balls

    constructor: () ->
        @material = material

    addChildGeom: (geom, mat) =>
        mesh = new THREE.Mesh geom, mat
        scene.add mesh
    # 
    # addOutline: (selected) => new THREE.Mesh selected.geometry, material.outline
    # 
    addSphere: (radius) =>
        geom = new THREE.IcosahedronGeometry radius, 4
        @addChildGeom geom, @material.sphere

    # addSpike: (file, prt) =>
    #     geom = new THREE.OctahedronGeometry 0.5
    #     @addChildGeom geom, @material.spike
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


module.exports = Balls
