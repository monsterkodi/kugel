###
 0000000   00000000   00000000 
000   000  000   000  000   000
000000000  00000000   00000000 
000   000  000        000      
000   000  000        000      
###

fs        = require 'fs'
remote    = require 'remote'
ipc       = require 'ipc'
keyname   = require './js/tools/keyname'

knix    = require './js/knix/knix'
klog    = require './js/knix/log'
error   = require './js/knix/error'
warning = require './js/knix/warning'
Console = require './js/knix/console'

OrbitControls = require('three-orbit-controls')(THREE)

win = remote.getCurrentWindow()

jsonStr = (a) -> JSON.stringify a, null, " "

console.log   = () -> ipc.send 'console.log',   [].slice.call arguments, 0
console.error = () -> ipc.send 'console.error', [].slice.call arguments, 0

log = () -> 
    # console.log [].slice.call(arguments, 0)
    klog.apply klog, [].slice.call(arguments, 0)
dbg = () -> 
    # console.log [].slice.call(arguments, 0)
    klog.apply klog, [].slice.call(arguments, 0)

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
        
    log 'dom:loaded'
            
    scene = new (THREE.Scene)

    # dbg 'scene', scene

    scene.fog = new THREE.FogExp2 0x000000, 0.01
    camera    = new THREE.PerspectiveCamera 75, window.innerWidth / window.innerHeight, 0.1, 1000
    renderer  = new THREE.WebGLRenderer antialias: true
    renderer.setSize window.innerWidth, window.innerHeight
    renderer.setClearColor 0x888888
    document.body.appendChild renderer.domElement

    controls = new OrbitControls camera
    controls.damping = 0.2
    controls.minDistance = 2
    controls.maxDistance = 100

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
    sun.position.set 1, 0, 0
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
        plnt.rotation.y += 0.002
        
        requestAnimationFrame render
        renderer.render scene, camera
        stats?.update()
        controls?.update()
        return

    onWindowResize = ->
        camera.aspect = window.innerWidth / window.innerHeight
        camera.updateProjectionMatrix()
        renderer.setSize window.innerWidth, window.innerHeight

    window.addEventListener 'resize', onWindowResize, false
            
    render()
    console.log 'loaded'    

win.on 'close', (event) ->
win.on 'focus', (event) -> 

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
    switch key
        when 'command+k'  
            new Console()
        when 'command+c'
            knix.closeAllWindows()
        
document.on 'keydown', onKeyDown
