# found in http://threejs.org/examples/webgl_geometry_text2.html 

material = new THREE.MeshFaceMaterial [
		new THREE.MeshPhongMaterial( { color: 0xffffff, shading: THREE.FlatShading } ),
		new THREE.MeshPhongMaterial( { color: 0xffffff, shading: THREE.SmoothShading } )
	]
    
class Text
    
    constructor: (text, scale=1.0) -> 
        textGeo = new THREE.TextGeometry text,
            size:            20
            height:          4
            curveSegments:   16
            font:            "helvetiker"
            weight:          "bold"
            style:           "normal"
            bevelEnabled:    true
            bevelThickness:  1.5
            bevelSize:       1
            material:        0
            extrudeMaterial: 0
        
        textGeo.computeBoundingBox()
        textGeo.computeVertexNormals()

        @mesh            = new (THREE.Mesh)(textGeo, material)
        @scale           = scale
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
        scene.add @mesh
        
    remove: () =>
        scene.remove @mesh
        delete @mesh
        
    setPos: (x,y) => 
        @mesh.position.x = @centerOffset+x
        @mesh.position.y = y

module.exports = Text
