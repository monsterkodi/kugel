log = require './knix/log'
dbg = require './knix/log'

class Boxes

    constructor: (@material) ->
        @dirs = {}
        @maxMeshDepth = 4
        @numChars = 0
        @minTextScale = 0.005
        
    relScaleForNode: (node, prt) => node.size / prt.size

    updateNodeScale: (node, prt) =>
        prtscale = prt.scale
        relscale = @relScaleForNode node, prt
        node.scale = prtscale * relscale
        @checkTextScale node
        if node.mesh?
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
                if child.mesh?
                    @updateChildrenScale child
        for file in prt.files
            @updateNodeScale file, prt
            prt.ci -= @relScaleForNode(file, prt)

    addChildGeom: (node, prt, geom, mat) =>
        mesh = new THREE.Mesh geom, mat
        scene.add mesh
        mesh.node = node
        node.mesh = mesh

    walkEnd: (dirname) => @updateChildrenScale @dirs['.']

    addDir: (dir, prt) =>
        dir.depth = prt.depth+1 if prt?
        if dir.depth <= @maxMeshDepth
            geom = new THREE.BoxGeometry 1, 1, 1
            @addChildGeom dir, prt, geom, @material.dir_node
            @addNodeText dir
        if not prt?
            dir.mesh.scale.x = dir.mesh.scale.y = dir.mesh.scale.z = 100
        
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
        @updateChildrenScale @dirs['.']
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
        return if node.depth > 1
        name = node.name
        name = path.basename resolve @rootDir if name == '.'
        name = "/" if name.length == 0  
        segm = Math.min(Math.max(1, Math.round(node.scale / 0.01)), 8)
        
        if node.scale > @minTextScale or node.files?
            @numChars += name.length
            # console.log @numChars
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
                node.text.setPos 0, 0, 0.52

    checkTextScale: (node) =>
        return if node.depth > 1 or node.files?
        if node.text? and node.scale < @minTextScale
            @numChars -= node.name.length
            # console.log @numChars
            node.mesh.remove node.text.mesh
            node.text = null

    refreshNodeText: (node) =>
        return if node.depth > 1
        @checkTextScale node
        if node.text?
            segm = Math.min(Math.max(1, Math.round(node.scale / 0.01)), 8)
            if node.text.config.segments != segm
                node.mesh.remove node.text.mesh
                @addNodeText node

    nextLevel: () =>
        for child in @dirs['.'].files
            @refreshNodeText child
        for childname in @dirs['.'].dirs
            @refreshNodeText @dirs[childname]

module.exports = Boxes
