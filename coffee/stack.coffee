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
    dir:        0xff8800
    file:       0x4444ff
    selected:   0xffffff

material = 
    dir_node: new THREE.MeshPhongMaterial
        color:              color.dir
        side:               THREE.FrontSide
        shading:            THREE.FlatShading
        transparent:        false
        shininess:          30
        
    file_node: new THREE.MeshPhongMaterial
        color:              color.file
        side:               THREE.FrontSide
        shading:            THREE.FlatShading
        transparent:        false
        shininess:          30
      
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
        
    outline:   new THREE.MeshBasicMaterial 
        color:       0xffffff
        side:        THREE.BackSide

###
 0000000  000000000   0000000    0000000  000   000
000          000     000   000  000       000  000 
0000000      000     000000000  000       0000000  
     000     000     000   000  000       000  000 
0000000      000     000   000   0000000  000   000
###

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
    relScaleForNode: (node, prt) => 0.9 /  @rowCols(prt)

    updateNodeScale: (node, prt) =>
        prtscale = prt.scale
        relscale = @relScaleForNode node, prt
        node.scale = prtscale * relscale
        @checkTextScale node
        if node.mesh?
            node.mesh.scale.x = node.mesh.scale.y = node.mesh.scale.z = 100*node.scale
            if prt?
                d = 100 * prt.scale / @rowCols(prt)
                node.mesh.position.x = prt.mesh.position.x + prt.cx * d - prt.scale * 50 + d/2
                node.mesh.position.y = prt.mesh.position.y - prt.cy * d + prt.scale * 50 - d/2
                node.mesh.position.z = prt.mesh.position.z + (prt.depth and 50 * prt.scale or 5) + 50 * node.scale

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

    walkEnd: (dirname) => @updateChildrenScale @dirs[dirname]

    addOutline: (selected) => 
        outline = new THREE.Mesh selected.geometry, material.outline
        outline.scale.multiplyScalar 1.05
        outline.position.z = 0.03
        outline

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
            # geom = new THREE.CylinderGeometry .5, .5, 1, 8, 1, false
            # geom = new THREE.TorusGeometry .3, .2, 16, 8
            # geom = new THREE.DodecahedronGeometry .6
            # geom = new THREE.IcosahedronGeometry .6
            @addChildGeom file, prt, geom, @material.file_node
            # file.mesh.rotation.x = Math.PI/3
        @addSize prt, file.size
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
