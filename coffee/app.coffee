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
walk    = require 'walkdir'
path    = require 'path'

knix    = require './js/knix/knix'
log     = require './js/knix/log'
dbg     = require './js/knix/log'
error   = require './js/knix/error'
warning = require './js/knix/warning'
Console = require './js/knix/console'
Text    = require './js/text'

rootDir      = '.'
walkDepth    = 4
win          = remote.getCurrentWindow()
scene        = null
camera       = null
text         = null
lookAtTarget = new THREE.Vector3()
maxCamDist   = 150
minCamDist   = 0.002
perspective  = false 

jsonStr = (a) -> JSON.stringify a, null, " "

console.log   = () -> ipc.send 'console.log',   [].slice.call arguments, 0
console.error = () -> ipc.send 'console.error', [].slice.call arguments, 0

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

    if perspective
        camera = new THREE.PerspectiveCamera 75, window.innerWidth / window.innerHeight, 0.001, 200
    else
        camera = new THREE.OrthographicCamera window.innerWidth/-2, window.innerWidth/2, window.innerHeight/2, window.innerHeight/-2, 0.001, 200
    camera.position.z = maxCamDist        
    renderer  = new THREE.WebGLRenderer antialias: true
    renderer.setSize window.innerWidth, window.innerHeight
    renderer.setClearColor 0x888888
    document.body.appendChild renderer.domElement

    sun = new THREE.DirectionalLight 0xeeeeee
    sun.position.set -1, 1, 1
    scene.add sun

    light = new THREE.AmbientLight 0x000000
    scene.add light

    if false
        stats = new Stats
        stats.domElement.style.position = 'absolute'
        stats.domElement.style.top = '0px'
        stats.domElement.style.zIndex = 100
        container.appendChild stats.domElement

    render = ->
        requestAnimationFrame render
        renderer.render scene, camera
        stats?.update()
        return

    onWindowResize = ->
        camera.aspect = window.innerWidth / window.innerHeight
        camera.updateProjectionMatrix()
        renderer.setSize window.innerWidth, window.innerHeight

    onMouseMove = (e) ->
        mouse   = new THREE.Vector2()
        mouse.x = 2 * (e.clientX / window.innerWidth) - 1
        mouse.y = 1 - 2 * ( e.clientY / window.innerHeight )
        selectAt mouse
        
    scale = 1
    onMouseWheel = (e) ->
        delta = e.wheelDelta
        camera.lookAt lookAtTarget
        if perspective
            camera.position.z *= 1-delta/10000
            camera.position.z = maxCamDist if camera.position.z > maxCamDist
            camera.position.z = minCamDist if camera.position.z < minCamDist
        else
            scale *= 1-delta/10000
            scale = 1 if scale > 1
            scale = 0.000001 if scale < 0.000001
            w = window.innerWidth * scale
            h = window.innerHeight * scale
            camera.left = w/-2
            camera.right = w/2
            camera.top = h/2
            camera.bottom = h/-2
        camera.updateProjectionMatrix()

    window.addEventListener 'mousemove',   onMouseMove, false
    window.addEventListener 'resize',   onWindowResize, false
    window.addEventListener 'mousewheel', onMouseWheel, true
            
    render()
    
    doWalk rootDir
    
    text = new Text rootDir
    text.mesh.position.y = 50

###
 0000000  00000000  000      00000000   0000000  000000000  000   0000000   000   000
000       000       000      000       000          000     000  000   000  0000  000
0000000   0000000   000      0000000   000          000     000  000   000  000 0 000
     000  000       000      000       000          000     000  000   000  000  0000
0000000   00000000  0000000  00000000   0000000     000     000   0000000   000   000
###

selected  = undefined
raycaster = new THREE.Raycaster()
selectAt  = (mouse) ->
    raycaster.setFromCamera mouse, camera
    intersects = raycaster.intersectObjects scene.children        
    if selected?
        selected.material.wireframe = false
    if intersects.length
        selected = intersects[intersects.length-1].object
        selected.material.wireframe = true
        text?.remove()
        name = selected.file?.name or selected.dir?.name
        name = rootDir if name == '.'
        scale = selected.file?.scale or selected.dir?.scale
        text = new Text name, scale
        text.setPos 0, selected.position.y + 50*scale

win.on 'close', (event) ->
win.on 'focus', (event) -> 

item_material = () -> 
    new THREE.MeshLambertMaterial 
        color:              0x888888, 
        side:               THREE.FrontSide
        shading:            THREE.FlatShading, 
        transparent:        true
        wireframe:          false
        depthTest:          false
        doubleSided:        false
        opacity:            0.2
        wireframeLinewidth: 2

###
0000000    000  00000000    0000000
000   000  000  000   000  000     
000   000  000  0000000    0000000 
000   000  000  000   000       000
0000000    000  000   000  0000000 
###

dirs = {}

addChildGeom = (dir, prt, geom) ->
    mesh = new THREE.Mesh geom, item_material()
    s = dir.size/dirs['.'].size
    ss = 100*s
    mesh.scale.x = mesh.scale.y = mesh.scale.z = ss
    scene.add mesh
    mesh.dir = dir
    dir.mesh = mesh
    dir.scale = s
    dir.ci = 0.5
    if prt?
        relscale = s/prt.scale
        mesh.position.y = prt.mesh.position.y + (prt.ci - relscale*0.5)*100*prt.scale
        prt.ci -= relscale    

addDir = (dir, prt) ->
    geom = new THREE.IcosahedronGeometry 0.5, 2
    addChildGeom dir, prt, geom

addFile = (file, prt) ->
    geom = new THREE.OctahedronGeometry 0.5
    addChildGeom file, prt, geom

addBelow = (dir, prt) ->
    addDir dir, prt
    for childname in dir.dirs
        child = dirs[childname]
        if child.size > 0
            addBelow child, dir
    for file in dir.files
        addFile file, dir

addDirSize = (dir, size) ->
    dirs[dir].size += size
    if dir != '.'
        addDirSize path.dirname(dir), size

addToParentDir = (dir) ->
    dirs[path.dirname(dir)]?.dirs.push dir

newDir = (dirname) -> dirs[dirname] = { files: [], size: 0, dirs: [], name:dirname, y: 0 }
    
###
000   000   0000000   000      000   000
000 0 000  000   000  000      000  000 
000000000  000000000  000      0000000  
000   000  000   000  000      000  000 
00     00  000   000  0000000  000   000
###
    
doWalk = (dirPath) ->
    resolved = resolve dirPath
    log 'walk', resolved
    num_files = 0
    num_dirs = 0
    opts = 
        "max_depth": walkDepth
    w = walk resolved, opts
    w.ignore ['electron-packager', 'electron-prebuild']
    l = resolved.length + 1    
    newDir '.'
    w.on 'file', (filename, stat) -> 
        num_files += 1
        file = filename.substr l      
        dir = path.dirname file
        if dirs[dir]?
            addDirSize dir, stat.size
            dirs[dir].files.push
                name: path.basename file
                size: stat.size
        else
            log 'WTF?'
                
    w.on 'directory', (dirname, stat) -> 
        num_dirs += 1
        dir = dirname.substr l
        newDir dir
        addToParentDir dir
        
    w.on 'end', ->
        log 'files:', num_files, 'dirs:', num_dirs
        addBelow dirs['.']

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
