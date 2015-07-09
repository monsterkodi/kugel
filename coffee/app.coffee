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

OrbitControls = require('three-orbit-controls')(THREE)

win    = remote.getCurrentWindow()
scene  = null
camera = null
text   = null

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

    camera    = new THREE.PerspectiveCamera 75, window.innerWidth / window.innerHeight, 0.001, 200
    renderer  = new THREE.WebGLRenderer antialias: true
    renderer.setSize window.innerWidth, window.innerHeight
    renderer.setClearColor 0x888888
    document.body.appendChild renderer.domElement

    controls = new OrbitControls camera
    controls.damping = 0.999
    controls.minDistance = .002
    controls.maxDistance = 150
    camera.position.z = 150

    sun = new THREE.DirectionalLight 0xeeeeee
    sun.position.set 1, 1, 1
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
        controls?.update()
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

    window.addEventListener 'mousemove', onMouseMove, false
    window.addEventListener 'resize', onWindowResize, false
            
    render()
    
    doWalk '.'
    
    text = new Text path.basename path.resolve('.')
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
        dbg selected.dir.name 
        text?.remove()
        text = new Text selected.dir.name, selected.dir.scale
        text.setPos selected.position.x, 50*selected.dir.scale

win.on 'close', (event) ->
win.on 'focus', (event) -> 

###
000   000   0000000   000      000   000
000 0 000  000   000  000      000  000 
000000000  000000000  000      0000000  
000   000  000   000  000      000  000 
00     00  000   000  0000000  000   000
###

dirs = {}
addDir = (dir) ->

    geometry = new THREE.IcosahedronGeometry 0.5, 1
    material = new THREE.MeshLambertMaterial 
        color:              0x888888, 
        side:               THREE.FrontSide
        shading:            THREE.FlatShading, 
        transparent:        true
        wireframe:          false
        depthTest:          false
        doubleSided:        false
        opacity:            0.2
        wireframeLinewidth: 2

    mesh = new THREE.Mesh geometry, material
    s = dir.size/dirs['.'].size
    ss = 100*s
    mesh.scale.x = ss
    mesh.scale.y = ss
    mesh.scale.z = ss
    scene.add mesh
    mesh.dir = dir
    dir.mesh = mesh
    dir.scale = s

addBelow = (dir) ->
    addDir dir
    ci = -0.5
    for childname in dir.dirs
        child = dirs[childname]
        if child.size > 0
            addBelow child
            dbg dir.mesh.position.x, ci, child.scale, dir.scale
            child.mesh.position.x = dir.mesh.position.x + (ci + child.scale*0.5)*100*dir.scale
            dbg child.mesh.position.x
            ci += child.scale
    dir

addDirSize = (dir, size) ->
    dirs[dir].size += size
    if dir != '.'
        addDirSize path.dirname(dir), size

addToParentDir = (dir) ->
    dirs[path.dirname(dir)]?.dirs.push dir

newDir = (dirname) -> dirs[dirname] = { files: [], size: 0, dirs: [], name:dirname }
    
doWalk = (dirPath) ->
    resolved = resolve dirPath
    log 'walk', resolved
    num_files = 0
    num_dirs = 0
    opts = 
        "max_depth": 3 #Infinity
    w = walk resolved, opts
    l = resolved.length + 1    
    newDir '.'
    w.on 'file', (filename, stat) -> 
        num_files += 1
        file = filename.substr l      
        dir = path.dirname file
        if dirs[dir]?
            addDirSize dir, stat.size
            dirs[dir].files.push 
                file: path.basename file
                size: stat.size
        else
            log 'WTF?'
                
    w.on 'directory', (filename, stat) -> 
        num_dirs += 1
        dir = filename.substr l
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
