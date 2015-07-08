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
        console: 'maximized'
        
    scene = new (THREE.Scene)

    # scene.fog = new THREE.FogExp2 0x000000, 0.01
    camera    = new THREE.PerspectiveCamera 75, window.innerWidth / window.innerHeight, 0.001, 200
    renderer  = new THREE.WebGLRenderer antialias: true
    renderer.setSize window.innerWidth, window.innerHeight
    renderer.setClearColor 0x888888
    document.body.appendChild renderer.domElement

    controls = new OrbitControls camera
    controls.damping = 0.999
    controls.minDistance = .002
    controls.maxDistance = 150
    controls.distance = 150

    if false
        geometry = new THREE.IcosahedronGeometry 1, 3
        moon_mat = new THREE.MeshLambertMaterial color:0xffffff, shading: THREE.SmoothShading
        plnt_mat = new THREE.MeshLambertMaterial color:0x8888ff, shading: THREE.SmoothShading

        plnt = new THREE.Mesh geometry, plnt_mat
        moon = new THREE.Mesh geometry, moon_mat
        moon.scale.x = 0.3
        moon.scale.y = 0.3
        moon.scale.z = 0.3
        moon.position.x = 6

        plnt.add moon
        scene.add plnt

        moon_light = new THREE.PointLight 0xffffff, 0.1, 100
        moon.add moon_light

    camera.position.z = 8

    sun = new THREE.DirectionalLight 0xeeeeee
    sun.position.set 1, 1, 1
    scene.add sun

    light = new THREE.AmbientLight 0x000000
    scene.add light

    raycaster = new THREE.Raycaster()
    mouse     = new THREE.Vector2()

    if false
        stats = new Stats
        stats.domElement.style.position = 'absolute'
        stats.domElement.style.top = '0px'
        stats.domElement.style.zIndex = 100
        container.appendChild stats.domElement

    render = ->
        plnt?.rotation.y += 0.002
        
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
        if intersects.length
            for i in [0..intersects.length]
                obj = intersects[i].object
                obj.material.color.setRGB(1,0,0)

    window.addEventListener 'mousemove', onMouseMove, false
    window.addEventListener 'resize', onWindowResize, false
            
    render()
    
    doWalk '.'
    # log 'loaded'    

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
    # return if dir.size == 0
    geometry = new THREE.IcosahedronGeometry 1, 2
    material = new THREE.MeshLambertMaterial 
        color:              0x888888, 
        side:               THREE.FrontSide
        shading:            THREE.FlatShading, 
        # blending:           THREE.AdditiveBlending
        transparent:        true
        wireframe:          false
        doubleSided:        false
        opacity:            0.2
        wireframeLinewidth: 4

    mesh = new THREE.Mesh geometry, material
    s = 10*dir.size/dirs['.'].size
    # dbg name, s
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
            # log dir, file
            addDirSize dir, stat.size
            dirs[dir].files.push 
                file: path.basename file
                size: stat.size
        else
            log 'WTF?'
                
    w.on 'directory', (filename, stat) -> 
        num_dirs += 1
        dir = filename.substr l
        # log 'dir: ', dir
        dirs[dir] = { files: [], size: 0, dirs: [], name:dir }
        addToParentDir dir
    w.on 'end', ->
        log 'files:', num_files, 'dirs:', num_dirs
        
        # log dirs['.']
        
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
