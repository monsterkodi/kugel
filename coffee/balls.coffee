log   = require './knix/log'
dbg   = require './knix/log'
tools = require './knix/tools'
clamp = tools.clamp

###
00     00   0000000   000000000  00000000  00000000   000   0000000   000    
000   000  000   000     000     000       000   000  000  000   000  000    
000000000  000000000     000     0000000   0000000    000  000000000  000    
000 0 000  000   000     000     000       000   000  000  000   000  000    
000   000  000   000     000     00000000  000   000  000  000   000  0000000
###

color = 
    dir:        0x888888
    file:       0x4444ff
    selected:   0xffffff

material = 
    dir_node: new THREE.MeshPhongMaterial
        color:              color.dir
        side:               THREE.FrontSide
        shading:            THREE.FlatShading
        transparent:        true
        shininess:          -3
        wireframe:          false
        depthTest:          false
        depthWrite:         false
        opacity:            0.2
        wireframeLinewidth: 2
        
    file_node: new THREE.MeshPhongMaterial
        color:              color.file
        side:               THREE.FrontSide
        shading:            THREE.FlatShading
        transparent:        true
        shininess:          -5
        wireframe:          false
        depthTest:          false
        depthWrite:         false
        opacity:            0.2
        wireframeLinewidth: 2
      
    dir_text:  new THREE.MeshPhongMaterial  
        color:       0xffffff
        shading:     THREE.FlatShading
        transparent: true
        opacity:     1.0
        
    file_text: new THREE.MeshPhongMaterial 
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
0000000    000   000  0000000  0000000  0000000 
###

class Balls

    constructor: () ->
        @material = material
        @dirs = {}
        
    dirFileRatio: (prt) => prt.dirs.length / (prt.dirs.length + prt.files.length)

    dirFileSizes: (dir) => 
        s = 0
        for file in dir.files
            s += file.size
        s

    dirSize: (dir) => Math.max 1, dir.files.length + dir.dirs.length
    dirDirSizes: (dir) =>
        s = 0
        for child in dir.dirs
            s += @dirSize @dirs[child]
        s

    relScaleForNode: (node, prt) =>   
        if node.files?
            relscale = @dirFileRatio(prt) * @dirSize(node) / @dirDirSizes(prt)
        else
            relscale = (1-@dirFileRatio(prt)) * node.size / @dirFileSizes(prt)
        relscale

    updateNodeScale: (node, prt) =>
        prtscale = relscale = 1
        if prt?
            prtscale = prt.scale
            relscale = @relScaleForNode node, prt
        node.scale = prtscale * relscale
        node.mesh.scale.x = node.mesh.scale.y = node.mesh.scale.z = 100*node.scale
        if prt?
            node.mesh.position.y = prt.mesh.position.y + (prt.ci - relscale*0.5)*100*prtscale

    updateChildrenScale: (prt) =>
        prt.ci = 0.5
        for name in prt.dirs
            child = @dirs[name]
            if child?
                @updateNodeScale child, prt
                prt.ci -= @relScaleForNode(child, prt)
                @updateChildrenScale child
        for file in prt.files
            @updateNodeScale file, prt
            prt.ci -= @relScaleForNode(file, prt)

    addChildGeom: (node, prt, geom, mat) =>
        mesh = new THREE.Mesh geom, mat
        scene.add mesh
        mesh.node = node
        node.mesh = mesh
        if prt?
            @updateChildrenScale prt
        else
            mesh.scale.x = mesh.scale.y = mesh.scale.z = 100

    walkEnd: (dirname) =>
        @updateChildrenScale @dirs[path.dirname dirname]

    addOutline: (selected) => new THREE.Mesh selected.geometry, material.outline

    addDir: (dir, prt) =>
        dir.depth = prt.depth+1 if prt?
        geom = new THREE.IcosahedronGeometry 0.5, Math.max(1, 2 - dir.depth)
        @addChildGeom dir, prt, geom, @material.dir_node
        @addNodeText dir

    addFile: (file, prt) =>
        file.depth = prt.depth+1
        geom = new THREE.OctahedronGeometry 0.5
        @addChildGeom file, prt, geom, @material.file_node
        if prt.depth == 0
            @addNodeText file

    clear: () =>
        for name, dir of @dirs
            scene.remove dir.mesh
            for file in dir.files
                scene.remove file.mesh
        @dirs = {}

    newDir: (dirname) =>
        @dirs[dirname] = 
            dirs:  []
            files: []
            size:  0
            depth: 0
            scale: 1
            y:     0
            name:  dirname
            path:  @rootDir + '/' + dirname

    ###
    000000000  00000000  000   000  000000000
       000     000        000 000      000   
       000     0000000     00000       000   
       000     000        000 000      000   
       000     00000000  000   000     000   
    ###

    addNodeText: (node) =>
        return if node.depth > 1
        name = node.name
        name = path.basename resolve @rootDir if name == '.'
        name = "/" if name.length == 0  
        segm = clamp 1, 8, Math.round node.scale / 0.01
        
        node.text = new Text
            text:     name
            bevel:    node.depth == 0
            scale:    node.depth == 0 and 0.005 or 0.01
            prt:      node.mesh
            material: node.files? and @material.dir_text or @material.file_text
            segments: segm
            
        if node.files?
            if node.depth == 0
                node.text.setPos 0, 0.58
            else 
                node.text.alignLeft()
                node.text.setPos 0.58, 0
        else
            node.text.setPos 0, 0, 0.52

    refreshNodeText: (node) =>
        return if node.depth > 1
        if node.text?
            segm = clamp 1, 8, Math.round node.scale / 0.01
            if node.text.config.segments != segm
                node.mesh.remove node.text.mesh
                @addNodeText node

    nextLevel: () =>
        for child in @dirs['.'].files
            @refreshNodeText child
        for childname in @dirs['.'].dirs
            @refreshNodeText @dirs[childname]

module.exports = Balls
