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
moment  = require 'moment'

knix    = require './js/knix/knix'
log     = require './js/knix/log'
dbg     = require './js/knix/log'
error   = require './js/knix/error'
warning = require './js/knix/warning'
Menu    = require './js/knix/menu'
Info    = require './js/info'
Console = require './js/knix/console'
Text    = require './js/text'
Dolly   = require './js/dolly'
Truck   = require './js/truck'
Balls   = require './js/balls'
Boxes   = require './js/boxes'
Stack   = require './js/stack'

# rootDir   = '~/Library/Caches/Firefox/Profiles/4knzbnkj.default/cache2/entries' 
# rootDir   = '~/Library'
# rootDir   = '~/Pictures/iPhoto/images'
rootDir   = '~'
walkDepth = 1 # Infinity
win       = remote.getCurrentWindow()
renderer  = null
camera    = null
nodes     = null
stats     = null
scene     = null
text      = null
dolly     = null
truck     = null
walk      = null
selected  = null
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

needsRender = true
anim = ->
    requestAnimationFrame anim
    if needsRender or camera.needsRender
        render()
        needsRender = false
        camera.needsRender = false
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
        # sortObjects:            false
        autoClear:              true
        
    renderer.setSize window.innerWidth, window.innerHeight
    renderer.setClearColor 0x222222
    document.body.appendChild renderer.domElement

    if false
        stats = new Stats
        stats.domElement.style.position = 'absolute'
        stats.domElement.style.top = '0px'
        stats.domElement.style.zIndex = 100
        container.appendChild stats.domElement

    onWindowResize = ->
        renderer.setSize window.innerWidth, window.innerHeight
        camera.aspect = window.innerWidth / window.innerHeight
        camera.updateProjectionMatrix()
        dolly?.zoom 1

    onMouseMove = (e) ->
        return if nodes?.isPivoting
        mouse.x = 2 * ( e.clientX / window.innerWidth ) - 1
        mouse.y = 1 - 2 * ( e.clientY / window.innerHeight )
        selectAt mouse
        
    onDoubleClick = (e) ->
        if selected and selected.node? and selected.node.name != '.'
            doWalk selected.node.path
        else 
            doWalk nodes.rootDir + '/..'
        
    mouseDownNode = null
    mouseDownPos = null    
    onMouseDown = (e) ->
        mouseDownNode = null
        mouseDownPos = new THREE.Vector2 e.clientX, e.clientY
        if selected and truck
            mouseDownNode = selected

    onMouseUp = (e) ->
        if selected and truck and selected == mouseDownNode
            mousePos = new THREE.Vector2 e.clientX, e.clientY
            if mouseDownPos.sub(mousePos).length() < 4
                truck.moveToTarget selected.position
        mouseDownNode = null
        mouseDownPos = null
        
    window.addEventListener 'dblclick',    onDoubleClick
    window.addEventListener 'mousedown',   onMouseDown
    window.addEventListener 'mouseup',     onMouseUp
    window.addEventListener 'mousemove',   onMouseMove
    window.addEventListener 'resize',      onWindowResize
            
    anim()
    nodes = new Stack
    doWalk rootDir    

###
000   000   0000000   0000000    00000000   0000000
0000  000  000   000  000   000  000       000     
000 0 000  000   000  000   000  0000000   0000000 
000  0000  000   000  000   000  000            000
000   000   0000000   0000000    00000000  0000000 
###
    
toggleNodes = () ->
    rootDir = nodes.rootDir
    nodes.clear()
    if nodes.constructor.name == 'Balls'
        nodes = new Boxes()
        dolly = new Dolly()
        camera = dolly.camera
        truck?.remove()
        truck = null
    else if nodes.constructor.name == 'Boxes'
        nodes = new Stack()
        truck = new Truck()
        camera = truck.camera        
        dolly?.remove()
        dolly = null
    else
        nodes = new Balls()
        dolly = new Dolly()
        camera = dolly.camera
        truck?.remove()
        truck = null
    doWalk rootDir 
    
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

    Menu.addButton btn,
        tooltip: 'style'
        keys:    ['i']
        icon:    'octicon-color-mode'
        action:  toggleNodes
    
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
    text?.remove()
    if intersects.length
        if nodes.stack?
            selected = intersects[0].object
            if selected == outline
                selected = intersects[1].object
        else
            selected = intersects[intersects.length-1].object
            if selected == outline
                selected = intersects[intersects.length-2].object
        return if outline?.name == selected.node.name
        if outline?
            outline.prt.remove outline
            outline = null
        if selected.node.name != '.'
            outline = nodes.addOutline selected
            outline.name = selected.node.name
            outline.prt = selected
            selected.add outline
            needsRender = true
            Info.value.current = "> " + selected.node.name

###
000   000   0000000   000      000   000
000 0 000  000   000  000      000  000 
000000000  000000000  000      0000000  
000   000  000   000  000      000  000 
00     00  000   000  0000000  000   000
###

timer = null
resumeWalk = () -> 
    walk?.resume()
    timer = null
startTime = null
timeSinceStart = () -> moment().subtract(startTime).format('m [m] s [s] SSS [ms]')
nowDirs = []
nextDirs = []

oneWalk = () ->
    timer = null
    if nowDirs.length == 0
        nodes.nextLevel()
        if Info.value.depth < walkDepth
            Info.value.depth += 1
            nowDirs  = nextDirs
            nextDirs = []
    if nowDirs.length == 0
        Info.value.time = timeSinceStart()
        Info.value.current = 'done'
        return
            
    dirPath = nowDirs.pop()
    currentDir = resolve(nodes.rootDir + '/' + dirPath)
    Info.value.current = currentDir.substr Info.value.root.length+1
    walk = walkDir currentDir, "max_depth": 1
    root = resolve nodes.rootDir
    l = root != "/" and root.length + 1 or 1
    
    walk.on 'file', (filename, stat) -> 

        file = path.basename filename
        dirname = path.dirname(filename).substr l
        dirname = '.' if dirname.length == 0
        dir = nodes.dirs[dirname]
        
        size = 1
        if stat.size
            size = Math.pow(stat.size, 1.0/2.0)
        dir.files.push
            name: file
            size: size
        nodes.addFile dir.files[dir.files.length-1], dir
        needsRender = true
        Info.value.files += 1
        Info.value.time = timeSinceStart()
        if Info.value.files % 5 == 0
            walk?.pause()
            timer = setTimeout resumeWalk, 1        
            
    walk.on 'directory', (dirname, stat) ->
        
        dirname = dirname.substr l
        nodes.newDir dirname
        dir = nodes.dirs[dirname]
        prt = nodes.dirs[path.dirname(dirname)]
        prt.dirs.push dir.name
        nodes.addDir dir, prt
        if dir.depth == Info.value.depth+1
            nowDirs.push dir.name
        else
            nextDirs.push dir.name
        needsRender = true
        Info.value.dirs += 1
        Info.value.time = timeSinceStart()
        if Info.value.dirs % 5 == 0
            walk?.pause()
            timer = setTimeout resumeWalk, 1
        
    walk.on 'end', ->
        walk = null
        nodes.walkEnd dirPath
        needsRender = true
        timer = setTimeout oneWalk, 1
            
doWalk = (dirPath) ->
    startTime = moment()
    resolved = resolve dirPath
    nodes.rootDir = resolved
    log 'walk', resolved
    nodes.clear()
    walk.stop() if walk?
    clearTimeout(timer) if timer?
    text?.remove()
    l = resolved != "/" and resolved.length + 1 or 1
    nodes.newDir '.'
    nodes.addDir nodes.dirs['.']
    needsRender        = true
    Info.value.root    = resolved
    Info.value.current = resolved
    Info.value.dirs    = 0
    Info.value.files   = 0
    Info.value.depth   = 0
    Info.value.time    = 'start'
    nowDirs            = ['.']
    nextDirs           = []
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
