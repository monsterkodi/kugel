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
    background: 0x222222
    dir:        0xff8800
    file:       0x4444ff
    selected:   0xffffff
    sun:        0xffffff

material = 
    dir_node: new THREE.MeshPhongMaterial
        color:              color.dir
        side:               THREE.FrontSide
        shading:            THREE.FlatShading
        transparent:        false
        wireframe:          false
        depthTest:          true
        depthWrite:         true
        shininess:          -5
        opacity:            0.25
        wireframeLinewidth: 2
        
    file_node: new THREE.MeshPhongMaterial
        color:              color.file
        side:               THREE.FrontSide
        shading:            THREE.FlatShading
        transparent:        false
        wireframe:          false
        depthTest:          true
        depthWrite:         true
        shininess:          -5
        opacity:            0.25
        wireframeLinewidth: 2
      
    dir_text:  new THREE.MeshPhongMaterial  
        color:       0xffffff
        shading:     THREE.FlatShading
        transparent: true
        opacity:     1
        
    file_text: new THREE.MeshPhongMaterial 
        color:       0x8888ff
        shading:     THREE.FlatShading
        transparent: true
        opacity:     1
        
    outline:   new THREE.MeshPhongMaterial 
        transparent: true,
        shading:     THREE.SmoothShading
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

class Stack

    constructor: () ->
        @material = material
        @stack = true
        @dirs = {}
        @maxMeshDepth = 4
        @numChars = 0
        @minTextScale = 0.005
        
    numChildNodes: (node) => node.files.length + node.dirs.length
    rowCols: (node) => Math.ceil Math.sqrt @numChildNodes node
    relScaleForNode: (node, prt) => 
        0.9 /  @rowCols(prt)
        # (node.size/prt.size)/@rowCols(prt)
        # Math.sqrt(node.size) / Math.sqrt(prt.size)

    updateNodeScale: (node, prt) =>
        prtscale = prt.scale
        relscale = @relScaleForNode node, prt
        node.scale = prtscale * relscale
        @checkTextScale node
        if node.mesh?
            node.mesh.scale.x = node.mesh.scale.y = node.mesh.scale.z = 100*node.scale
            # if prt?
            #     node.mesh.position.y = prt.mesh.position.y + (prt.ci - relscale*0.5)*100*prtscale
            if prt?
                d = 100 * prt.scale / @rowCols(prt)
                node.mesh.position.x = prt.mesh.position.x + prt.cx * d - prt.scale * 50 + d/2
                node.mesh.position.y = prt.mesh.position.y - prt.cy * d + prt.scale * 50 - d/2
                node.mesh.position.z = prt.mesh.position.z + (prt.depth and 50 * prt.scale or 5) + 50 * node.scale
                # console.log node.name, node.mesh.position.z, @rowCols(prt), d, node.depth

    updateChildrenScale: (prt) =>
        prt.cx = 0
        prt.cy = 0
        for name in prt.dirs
            child = @dirs[name]
            if child?
                @updateNodeScale child, prt
                prt.cx += 1
                if prt.cx >= @rowCols(prt)
                    prt.cx = 0
                    prt.cy += 1
                # if child.mesh?
                #     @updateChildrenScale child
        for file in prt.files
            @updateNodeScale file, prt
            prt.cx += 1
            if prt.cx >= @rowCols(prt)
                prt.cx = 0
                prt.cy += 1

    addChildGeom: (node, prt, geom, mat) =>
        mesh = new THREE.Mesh geom, mat
        scene.add mesh
        mesh.node = node
        node.mesh = mesh

    walkEnd: (dirname) => 
        @updateChildrenScale @dirs[dirname]
        # @updateChildrenScale @dirs['.']

    addDir: (dir, prt) =>
        dir.depth = prt.depth+1 if prt?
        if dir.depth <= @maxMeshDepth
            geom = new THREE.BoxGeometry 1, 1, prt? and 1 or .1
            @addChildGeom dir, prt, geom, @material.dir_node
            @addNodeText dir
        if not prt?
            dir.mesh.scale.x = dir.mesh.scale.y = dir.mesh.scale.z = 100
            dir.mesh.position.z = -5
        
    parentDir: (dir) =>
        if dir.depth > 0
            @dirs[path.dirname(dir.name)]
        
    addSize: (dir, size) =>
        dir.size += size
        if prt = @parentDir dir
            @addSize prt, size
        
    addFile: (file, prt) =>
        file.depth = prt.depth+1
        if file.depth <= @maxMeshDepth
            geom = new THREE.BoxGeometry 1, 1, 1
            @addChildGeom file, prt, geom, @material.file_node
        @addSize prt, file.size
        # @updateChildrenScale @dirs['.']
        if prt.depth == 0
            @addNodeText file

    clear: () =>
        @numChars = 0
        for name, dir of @dirs
            scene.remove dir.mesh
            for file in dir.files
                scene.remove file.mesh
        @dirs = {}

    newDir: (dirname) =>
        @dirs[dirname] = 
            dirs:  []
            files: []
            size:  1
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
        return if node.depth > 0
        return if node.depth > 1
        name = node.name
        name = path.basename resolve @rootDir if name == '.'
        name = "/" if name.length == 0  
        segm = clamp 1, 8, Math.round node.scale / 0.01
        
        if node.scale > @minTextScale or node.files?
            @numChars += name.length
            node.text = new Text
                text:     name
                bevel:    node.depth == 0
                scale:    0.005
                prt:      node.mesh
                material: node.files? and @material.dir_text or @material.file_text
                segments: segm
            
            if node.files?
                if node.depth == 0
                    node.text.setPos 0, 0.58
                else
                    node.text.setPos 0, 0, 2.0
            else
                node.text.setPos 0, 0, 0.52

    checkTextScale: (node) =>
        return if node.depth > 1 or node.files?
        if node.text? and node.scale < @minTextScale
            @numChars -= node.name.length
            node.mesh.remove node.text.mesh
            node.text = null

    refreshNodeText: (node) =>
        return if node.depth > 1
        @checkTextScale node
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

module.exports = Stack
