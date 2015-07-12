###
 0000000   00000000   00000000 
000   000  000   000  000   000
000000000  00000000   00000000 
000   000  000        000      
000   000  000        000      
###

fs      = require 'fs'
remote  = require 'remote'
ipc     = require 'ipc'
keyname = require './js/tools/keyname'
resolve = require './js/tools/resolve'
walkDir = require 'walkdir'
path    = require 'path'

knix    = require './js/knix/knix'
log     = require './js/knix/log'
dbg     = require './js/knix/log'
error   = require './js/knix/error'
warning = require './js/knix/warning'
Console = require './js/knix/console'
Text    = require './js/text'
Dolly   = require './js/dolly'

rootDir   = '~'
walkDepth = 1
win       = remote.getCurrentWindow()
renderer  = null
stats     = null
scene     = null
text      = null
dolly     = null
walk      = null
selected  = null
dirs      = {}

jsonStr = (a) -> JSON.stringify a, null, " "

console.log   = () -> ipc.send 'console.log',   [].slice.call arguments, 0
console.error = () -> ipc.send 'console.error', [].slice.call arguments, 0

###
00000000   00000000  000   000  0000000    00000000  00000000 
000   000  000       0000  000  000   000  000       000   000
0000000    0000000   000 0 000  000   000  0000000   0000000  
000   000  000       000  0000  000   000  000       000   000
000   000  00000000  000   000  0000000    00000000  000   000
###

render = -> 
    renderer.render scene, dolly.camera

needsRender = true
anim = ->
    requestAnimationFrame anim
    if needsRender or dolly.needsRender
        render()
        needsRender = false
        dolly.needsRender = false
    stats?.update()

###
00     00   0000000   000000000  00000000  00000000   000   0000000   000    
000   000  000   000     000     000       000   000  000  000   000  000    
000000000  000000000     000     0000000   0000000    000  000000000  000    
000 0 000  000   000     000     000       000   000  000  000   000  000    
000   000  000   000     000     00000000  000   000  000  000   000  0000000
###

color = 
    background: 0x222222
    dir:        0x888888
    file:       0x4444ff
    selected:   0xffffff
    sun:        0xffffff

dir_material = () -> 
    new THREE.MeshPhongMaterial
        color:              color.dir
        side:               THREE.FrontSide
        shading:            THREE.FlatShading
        transparent:        true
        shininess:          -3
        wireframe:          false
        depthTest:          false
        doubleSided:        false
        opacity:            0.2
        wireframeLinewidth: 2

file_material = () -> 
    new THREE.MeshPhongMaterial
        color:              color.file
        side:               THREE.FrontSide
        shading:            THREE.FlatShading
        transparent:        true
        shininess:          -5
        wireframe:          false
        depthTest:          false
        doubleSided:        false
        opacity:            0.2
        wireframeLinewidth: 2
    
material = 
    dir:  new THREE.MeshPhongMaterial { color: 0xffffff, shading: THREE.FlatShading }
    file: new THREE.MeshPhongMaterial { color: 0x8888ff, shading: THREE.FlatShading }

###
000       0000000    0000000   0000000    00000000  0000000  
000      000   000  000   000  000   000  000       000   000
000      000   000  000000000  000   000  0000000   000   000
000      000   000  000   000  000   000  000       000   000
0000000   0000000   000   000  0000000    00000000  0000000  
###

document.observe 'dom:loaded', ->
    
    knix.init
        console: 'shade'
        
    scene = new (THREE.Scene)

    dolly = new Dolly
        perspective: false
        maxDist:     100
        minDist:     0.002
    
    renderer = new THREE.WebGLRenderer antialias: true
    renderer.setSize window.innerWidth, window.innerHeight
    renderer.setClearColor color.background
    renderer.sortObjects = false
    renderer.autoClear = true
    document.body.appendChild renderer.domElement

    sun = new THREE.DirectionalLight color.sun
    sun.position.set -.3, 1, 1
    # sun.position.set -.2, .2, 1
    scene.add sun

    if false
        stats = new Stats
        stats.domElement.style.position = 'absolute'
        stats.domElement.style.top = '0px'
        stats.domElement.style.zIndex = 100
        container.appendChild stats.domElement

    onWindowResize = ->
        renderer.setSize window.innerWidth, window.innerHeight
        dolly.camera.aspect = window.innerWidth / window.innerHeight
        dolly.zoom 1

    onMouseMove = (e) ->
        return if dolly.isPivoting
        mouse   = new THREE.Vector2()
        mouse.x = 2 * (e.clientX / window.innerWidth) - 1
        mouse.y = 1 - 2 * ( e.clientY / window.innerHeight )
        selectAt mouse
        
    onDoubleClick = (e) ->
        if selected and selected.node? and selected.node.name != '.'
            rootDir = selected.node.path
            doWalk rootDir
        else 
            rootDir = resolve rootDir + '/..'
            doWalk rootDir
        
    window.addEventListener 'dblclick',  onDoubleClick
    window.addEventListener 'mousemove',   onMouseMove
    window.addEventListener 'resize',   onWindowResize
            
    anim()
    
    doWalk rootDir    
    
###
000000000  00000000  000   000  000000000
   000     000        000 000      000   
   000     0000000     00000       000   
   000     000        000 000      000   
   000     00000000  000   000     000   
###

displayTextForNode = (node) ->
    name = node.name
    name = path.basename resolve rootDir if name == '.'
    name = "/" if name.length == 0  
    text = new Text 
        text:  name
        scale: node.scale
    y = node.mesh.position.y
    if node.files?
        y += 58*node.scale 
    text.setPos 0, y
    
addNodeText = (node) ->
    return if node.depth > 1
    name = node.name
    name = path.basename resolve rootDir if name == '.'
    name = "/" if name.length == 0  
    node.text = new Text 
        text:  name
        scale: 0.01
        prt:   node.mesh
        material: node.files? and material.dir or material.file
        segments: Math.max(1, Math.round(node.scale * 8))
    if node.files?
        if node.depth == 0
            node.text.setPos 0, 0.58
        else 
            node.text.alignLeft()
            node.text.setPos 0.58, 0

###
 0000000  00000000  000      00000000   0000000  000000000  000   0000000   000   000
000       000       000      000       000          000     000  000   000  0000  000
0000000   0000000   000      0000000   000          000     000  000   000  000 0 000
     000  000       000      000       000          000     000  000   000  000  0000
0000000   00000000  0000000  00000000   0000000     000     000   0000000   000   000
###

raycaster = new THREE.Raycaster()
selectAt  = (mouse) ->
    raycaster.setFromCamera mouse, dolly.camera
    intersects = raycaster.intersectObjects scene.children   
    # if selected?
        # selected.material?.color?.set color.material
        # selected.material.shininess = -6
    selected = undefined
    text?.remove()
    if intersects.length
        selected = intersects[intersects.length-1].object
        # selected.material.color.set color.selected
        # selected.material.shininess = -6
        # displayTextForNode selected.node
        needsRender = true

###
0000000    000  00000000    0000000
000   000  000  000   000  000     
000   000  000  0000000    0000000 
000   000  000  000   000       000
0000000    000  000   000  0000000 
###

clearScene = () ->
    for name, dir of dirs
        scene.remove dir.mesh
        for file in dir.files
            scene.remove file.mesh

dirFileRatio = (prt) -> prt.dirs.length / (prt.dirs.length + prt.files.length)

dirFileSizes = (dir) -> 
    s = 0
    for file in dir.files
        s += file.size
    s

dirSize = (dir) -> Math.max 1, dir.files.length + dir.dirs.length
dirDirSizes = (dir) ->
    s = 0
    for child in dir.dirs
        s += dirSize dirs[child]
    s

relScaleForNode = (node, prt) ->   
    if node.files?
        relscale = dirFileRatio(prt) * dirSize(node) / dirDirSizes(prt)
    else
        relscale = (1-dirFileRatio(prt)) * node.size / dirFileSizes(prt)
    relscale

updateNodeScale = (node, prt) ->
    prtscale = relscale = 1
    if prt?
        prtscale = prt.scale
        relscale = relScaleForNode node, prt
    node.scale = prtscale * relscale
    node.mesh.scale.x = node.mesh.scale.y = node.mesh.scale.z = 100*node.scale
    if prt?
        node.mesh.position.y = prt.mesh.position.y + (prt.ci - relscale*0.5)*100*prtscale

updateChildrenScale = (prt) ->
    prt.ci = 0.5
    for name in prt.dirs
        child = dirs[name]
        if child?
            updateNodeScale child, prt
            prt.ci -= relScaleForNode(child, prt)
            updateChildrenScale child
        else
            console.log 'no child', name
    for file in prt.files
        updateNodeScale file, prt
        prt.ci -= relScaleForNode(file, prt)

addChildGeom = (node, prt, geom, mat) ->
    mesh = new THREE.Mesh geom, mat
    scene.add mesh
    mesh.node = node
    node.mesh = mesh
    if prt?
        updateChildrenScale prt 
    else
        mesh.scale.x = mesh.scale.y = mesh.scale.z = 100

addDir = (dir, prt) ->
    dir.depth = prt.depth+1 if prt?
    geom = new THREE.IcosahedronGeometry 0.5, Math.max(1, 2 - dir.depth)
    mat = dir_material()
    addChildGeom dir, prt, geom, mat
    addNodeText dir

addFile = (file, prt) ->
    file.depth = prt.depth+1
    geom = new THREE.OctahedronGeometry 0.5
    mat = file_material()
    addChildGeom file, prt, geom, mat
    if prt.depth == 0
        addNodeText file

newDir = (dirname) ->
    dirs[dirname] = 
        dirs:  []
        files: []
        size:  0
        depth: 0
        scale: 1
        y:     0
        name:  dirname
        path:  rootDir + '/' + dirname
    
###
000   000   0000000   000      000   000
000 0 000  000   000  000      000  000 
000000000  000000000  000      0000000  
000   000  000   000  000      000  000 
00     00  000   000  0000000  000   000
###

timer = null
resumeWalk = () -> 
    walk.resume()
    timer = null
currentLevel = 0
nowDirs = []
nextDirs = []
numDirs = 0
numFiles = 0
checkAbort = (dirname) ->
    if numFiles + numDirs > 5000
        clearTimeout(timer) if timer?
        walk.stop()
        log 'abort', dirname, numDirs, numFiles
        walk = null

oneWalk = () ->
    timer = null
    if nowDirs.length == 0
        if currentLevel < walkDepth
            currentLevel += 1
            log 'level', currentLevel, numDirs, numFiles
            nowDirs  = nextDirs
            nextDirs = []
    if nowDirs.length == 0
        log 'done', numDirs, numFiles
        return
            
    dirPath = nowDirs.pop()
    walk = walkDir resolve(rootDir + '/' + dirPath), "max_depth": 1
    root = resolve rootDir
    l = root != "/" and root.length + 1 or 1
    
    walk.on 'file', (filename, stat) -> 

        file = path.basename filename
        dirname = path.dirname(filename).substr l
        dirname = '.' if dirname.length == 0
        dir = dirs[dirname]
        dir.files.push
            name: file
            size: stat.size or 1
        addFile dir.files[dir.files.length-1], dir
        needsRender = true
        walk.pause()
        timer = setTimeout resumeWalk, 1
        numFiles += 1
        checkAbort dirname
            
    walk.on 'directory', (dirname, stat) ->
        
        dirname = dirname.substr l
        newDir dirname
        dir = dirs[dirname]
        prt = dirs[path.dirname(dirname)]
        prt.dirs.push dir.name
        addDir dir, prt
        if dir.depth == currentLevel+1
            nowDirs.push dir.name
        else
            nextDirs.push dir.name
        needsRender = true
        walk.pause()
        timer = setTimeout resumeWalk, 1
        numDirs += 1
        checkAbort dirname
        
    walk.on 'end', ->
        walk = null
        updateChildrenScale dirs[path.dirname dirPath]
        needsRender = true
        timer = setTimeout oneWalk, 1
            
doWalk = (dirPath) ->
    resolved = resolve dirPath
    log 'walk', resolved
    clearScene()
    walk.stop() if walk?
    clearTimeout(timer) if timer?
    dirs = {}
    text?.remove()
    l = resolved != "/" and resolved.length + 1 or 1
    newDir '.'
    addDir dirs['.']
    # displayTextForNode dirs['.']
    # addNodeText dirs['.']
    needsRender = true
    currentLevel = 0
    numDirs = 0
    numFiles = 0
    nowDirs = ['.']
    nextDirs = []
    oneWalk()
        
###
000   000  00000000  000   000  0000000     0000000   000   000  000   000
000  000   000        000 000   000   000  000   000  000 0 000  0000  000
0000000    0000000     00000    000   000  000   000  000000000  000 0 000
000  000   000          000     000   000  000   000  000   000  000  0000
000   000  00000000     000     0000000     0000000   00     00  000   000
###
            
onKeyDown = (event) ->
    key = keyname.ofEvent event
    e   = document.activeElement
    # dbg key
    switch key
        when 'command+e'
            doWalk '.'
        when 'command+k'  
            new Console()
        when 'command+c'
            knix.closeAllWindows()
        when 'command+q'
            ipc.send 'process.exit'
        
document.on 'keydown', onKeyDown
