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
path    = require 'path'
moment  = require 'moment'
clone   = require 'lodash.clone'

knix    = require './js/knix/knix'
log     = require './js/knix/log'
dbg     = require './js/knix/log'
Menu    = require './js/knix/menu'
Info    = require './js/info'
Console = require './js/knix/console'
Text    = require './js/text'
Truck   = require './js/truck'
Mesh    = require './js/mesh'
color   = require './js/color'
Game    = require './js/game'
Quat    = require './js/quat'
Vect    = require './js/vect'
vec     = Vect.new

win       = remote.getCurrentWindow()
renderer  = null
camera    = null
scene     = null
stats     = null
text      = null
dolly     = null
truck     = null
balls     = null
game      = null
mouse     = new THREE.Vector2()

jsonStr = (a) -> JSON.stringify a, null, " "

console.log   = () -> ipc.send 'console.log',   [].slice.call arguments, 0
console.error = () -> ipc.send 'console.error', [].slice.call arguments, 0
clog = console.log

###
00000000   00000000  000   000  0000000    00000000  00000000 
000   000  000       0000  000  000   000  000       000   000
0000000    0000000   000 0 000  000   000  0000000   0000000  
000   000  000       000  0000  000   000  000       000   000
000   000  00000000  000   000  0000000    00000000  000   000
###

render = -> 
    renderer.render scene, camera

clock = new THREE.Clock()
secs = 1.0/60.0
ssum = secs
scnt = 1
anim = () ->
    requestAnimationFrame anim
    # secs = Math.floor(1000*(secs*9+clock.getDelta())/10.0)/1000.0
    ssum += clock.getDelta()
    scnt += 1
    # secs = ssum/scnt
    step = 
        delta: secs*1000
        dsecs: secs
    game?.frame step
    render()
    stats?.update()

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
        
    initMenu()
        
    scene = new (THREE.Scene)

    truck = new Truck()
    camera = truck.camera
    
    renderer = new THREE.WebGLRenderer 
        antialias:              true
        logarithmicDepthBuffer: true
        autoClear:              true
        
    renderer.setSize window.innerWidth, window.innerHeight
    renderer.setClearColor color.space
    document.body.appendChild renderer.domElement

    game = new Game truck, renderer

    if true
        stats = new Stats()
        stats.domElement.style.position = 'fixed'
        stats.domElement.style.bottom = '0px'
        stats.domElement.style.right = '0px'
        stats.domElement.style.zIndex = 1000
        document.body.appendChild stats.domElement

    onWindowResize = ->
        renderer.setSize window.innerWidth, window.innerHeight
        camera.aspect = window.innerWidth / window.innerHeight
        camera.updateProjectionMatrix()
        dolly?.zoom 1

    onMouseMove = (e) ->
        mouse.x = 2 * ( e.clientX / window.innerWidth ) - 1
        mouse.y = 1 - 2 * ( e.clientY / window.innerHeight )
        game?.mouse mouse
        # selectAt mouse
        
    onDoubleClick = (e) ->

    mouseDownPos = null    
    onMouseDown = (e) ->
        mouseDownPos = new THREE.Vector2 e.clientX, e.clientY

    onMouseUp = (e) ->
        mousePos = new THREE.Vector2 e.clientX, e.clientY
        mouseDownPos = null
        
    window.addEventListener 'dblclick',    onDoubleClick
    window.addEventListener 'mousedown',   onMouseDown
    window.addEventListener 'mouseup',     onMouseUp
    window.addEventListener 'mousemove',   onMouseMove
    window.addEventListener 'resize',      onWindowResize
            
    anim()

    ball = new Mesh 
        type:   'sphere'
        radius: 100
        
    if 0
        new Mesh
            type:      'spike'
            radius:    6
            color:     0xff0000
            position:  vec(106,0,0)
        
        new Mesh
            type:      'spike'
            radius:    6
            color:     0x00ff00
            position:  vec(0,106,0)
        
        new Mesh
            type:      'spike'
            radius:    6
            color:     0x8888ff
            position:  vec(0,0,106)
        
        new Mesh
            type:      'spike'
            radius:    6
            color:     0xff0000
            wireframe: true
            position:  vec(-106, 0, 0)
                
        new Mesh
            type:      'spike'
            radius:    6        
            color:     0x00ff00
            wireframe: true
            position:  vec(0, -106, 0)

        new Mesh
            type:      'spike'
            radius:    6
            color:     0x8888ff
            wireframe: true
            position:  vec(0,0,-106)
                    
###
00     00  00000000  000   000  000   000
000   000  000       0000  000  000   000
000000000  0000000   000 0 000  000   000
000 0 000  000       000  0000  000   000
000   000  00000000  000   000   0000000 
###

initMenu = ->

    btn = 
        menu: 'menu'

    Menu.addButton btn,
        tooltip: 'info'
        icon:    'octicon-dashboard'
        action: Info.toggle
    
###
 0000000  00000000  000      00000000   0000000  000000000  000   0000000   000   000
000       000       000      000       000          000     000  000   000  0000  000
0000000   0000000   000      0000000   000          000     000  000   000  000 0 000
     000  000       000      000       000          000     000  000   000  000  0000
0000000   00000000  0000000  00000000   0000000     000     000   0000000   000   000
###

outline = null
raycaster = new THREE.Raycaster()
selectAt  = (mouse) ->
    return if truck?.isPivoting or dolly?.isPivoting
    raycaster.setFromCamera mouse, camera
    intersects = raycaster.intersectObjects scene.children   
    selected = undefined
    if intersects.length
        selected = intersects[0].object
        log intersects.length
            
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
