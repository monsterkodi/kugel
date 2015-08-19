###
00000000   000       0000000   000   000  00000000  000000000
000   000  000      000   000  0000  000  000          000   
00000000   000      000000000  000 0 000  0000000      000   
000        000      000   000  000  0000  000          000   
000        0000000  000   000  000   000  00000000     000   
###

tools    = require './knix/tools'
rndrng   = tools.rndrng

class Planet

    constructor: () ->
        @createRing()

    createRing: () =>
        
        geometry = new THREE.Geometry()
        
        particles = 6000
            
        sprite = THREE.ImageUtils.loadTexture "img/disc.png" 

        for i in [0..particles]
            r = rndrng(0,1)
            r = r * r
            v = vec 250 + r*100, 0, 0
            v.applyQuaternion Quat.axis Vect.Y, rndrng(-180,180)
            v.y += rndrng(0,10)
            geometry.vertices.push v
            geometry.colors.push new THREE.Color 0,0,rndrng(0.25,0.5)

        mat = new THREE.PointCloudMaterial 
            size:            5
            sizeAttenuation: true 
            map:             sprite 
            alphaTest:       0.5
            transparent:     true
            vertexColors:    THREE.VertexColors
            
        particles = new THREE.PointCloud geometry, mat
        
        scene.add particles           

module.exports = Planet
