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

OrbitControls = require('three-orbit-controls')(THREE)

win = remote.getCurrentWindow()
scene = null

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

    raycaster = new THREE.Raycaster()
    mouse     = new THREE.Vector2()
    selected  = undefined

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
        mouse.x = 2 * (e.clientX / window.innerWidth) - 1
        mouse.y = 1 - 2 * ( e.clientY / window.innerHeight )
        raycaster.setFromCamera( mouse, camera )
        intersects = raycaster.intersectObjects scene.children        
        if selected?
            selected.material.wireframe = false
        if intersects.length
            selected = intersects[intersects.length-1].object
            selected.material.wireframe = true

    window.addEventListener 'mousemove', onMouseMove, false
    window.addEventListener 'resize', onWindowResize, false
            
    render()
    
    doWalk '.'

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

    geometry = new THREE.IcosahedronGeometry 1, 2
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
    s = 10*dir.size/dirs['.'].size
    mesh.scale.x = s
    mesh.scale.y = s
    mesh.scale.z = s
    scene.add mesh
    dir.mesh = mesh
    dir.scale = s

addBelow = (dir) ->
    addDir dir
    ci = 0
    cn = dir.dirs.length
    for childname in dir.dirs
        child = dirs[childname]
        if child.size > 0
            addBelow child
            child.mesh.position.x = ci*dir.scale
            ci += 1

addDirSize = (dir, size) ->
    dirs[dir].size += size
    if dir != '.'
        addDirSize path.dirname(dir), size

addToParentDir = (dir) ->
    dirs[path.dirname(dir)]?.dirs.push dir

doWalk = (dirPath) ->
    resolved = resolve dirPath
    log 'walk', resolved
    num_files = 0
    num_dirs = 0
    opts = 
        "max_depth": 3 # Infinity
    w = walk resolved, opts
    l = resolved.length + 1    
    dirs['.'] = { files: [], size: 0, dirs: [], name:'.' }
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
        dirs[dir] = { files: [], size: 0, dirs: [], name:dir }
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
