log = require './knix/log'
dbg = require './knix/log'

class Balls

    constructor: (@material) ->
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
        # log dirname, @dirs[dirname]?
        @updateChildrenScale @dirs[dirname]

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
        segm = Math.min(Math.max(1, Math.round(node.scale / 0.01)), 8)
        
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
            segm = Math.min(Math.max(1, Math.round(node.scale / 0.01)), 8)
            if node.text.config.segments != segm
                node.mesh.remove node.text.mesh
                @addNodeText node

    nextLevel: () =>
        for child in @dirs['.'].files
            @refreshNodeText child
        for childname in @dirs['.'].dirs
            @refreshNodeText @dirs[childname]

module.exports = Balls
