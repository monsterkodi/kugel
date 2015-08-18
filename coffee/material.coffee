###
00     00   0000000   000000000  00000000  00000000   000   0000000   000    
000   000  000   000     000     000       000   000  000  000   000  000    
000000000  000000000     000     0000000   0000000    000  000000000  000    
000 0 000  000   000     000     000       000   000  000  000   000  000    
000   000  000   000     000     00000000  000   000  000  000   000  0000000
###

color = require './color'

module.exports = 
    sphere: new THREE.MeshPhongMaterial
        color:     color.sphere
        side:      THREE.FrontSide
        shading:   THREE.SmoothShading
        transparent: true
        opacity: 0.95
        shininess: 0

    snake: new THREE.MeshPhongMaterial
        color:     color.snake
        side:      THREE.FrontSide
        shading:   THREE.SmoothShading
        shininess: 0
        
    spike: new THREE.MeshPhongMaterial
        color:     color.spike
        side:      THREE.FrontSide
        shading:   THREE.FlatShading
        shininess: -5

    trail: new THREE.MeshPhongMaterial
        color:     color.trail
        side:      THREE.FrontSide
        shading:   THREE.FlatShading
        transparent: true
        opacity: 0.75
        shininess: 0
              
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
