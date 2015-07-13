# found in http://threejs.org/examples/webgl_geometry_text2.html 

material = new THREE.MeshFaceMaterial [
        new THREE.MeshPhongMaterial( { color: 0xffffff, shading: THREE.FlatShading } )
    ]
    
class Text
    
    constructor: (config) -> 
        
        textGeo = new THREE.TextGeometry config.text,
            size:            20
            height:          4
            curveSegments:   config.segments or 10
            font:            "helvetiker"
            weight:          "bold"
            style:           "normal"
            bevelEnabled:    config.bevel or false
            bevelThickness:  1.5
            bevelSize:       1
            material:        0
            extrudeMaterial: 0
        
        textGeo.computeBoundingBox()
        textGeo.computeVertexNormals()

        @config = config
        @mesh            = new (THREE.Mesh)(textGeo, config.material or material)
        @scale           = config.scale or 1
        @width           = textGeo.boundingBox.max.x - textGeo.boundingBox.min.x
        @centerOffset    = -0.5 * @width * @scale
        @mesh.position.x = @centerOffset
        @mesh.position.y = 0
        @mesh.position.z = 0
        @mesh.rotation.x = 0
        @mesh.scale.x    = @scale
        @mesh.scale.y    = @scale
        @mesh.scale.z    = @scale
        @mesh.rotation.y = Math.PI * 2
        if config.prt?
            config.prt.add @mesh
        else
            scene.add @mesh
        
    remove: () =>
        scene.remove @mesh
        delete @mesh
        
    setPos: (x,y,z) => 
        @mesh.position.x = @centerOffset+x
        @mesh.position.y = y
        @mesh.position.z = z if z?
        
    alignLeft: () =>
        @mesh.position.x -= @centerOffset
        @centerOffset = 0

module.exports = Text
