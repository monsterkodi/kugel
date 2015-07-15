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
Balls   = require './js/balls'
Boxes   = require './js/boxes'

# rootDir   = '~/Library/Caches/Firefox/Profiles/4knzbnkj.default/cache2/entries' 
# rootDir   = '~/Library'
rootDir   = '~/Pictures/iPhoto/images'
walkDepth = Infinity
win       = remote.getCurrentWindow()
renderer  = null
nodes     = null
stats     = null
scene     = null
text      = null
dolly     = null
walk      = null
selected  = null

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

material = 
    dir_node: new THREE.MeshPhongMaterial
        color:              color.dir
        side:               THREE.FrontSide
        shading:            THREE.FlatShading
        transparent:        true
        shininess:          -3
        wireframe:          false
        depthTest:          false
        depthWrite:         false
        opacity:            0.2
        wireframeLinewidth: 2
        
    file_node: new THREE.MeshPhongMaterial
        color:              color.file
        side:               THREE.FrontSide
        shading:            THREE.FlatShading
        transparent:        true
        shininess:          -5
        wireframe:          false
        depthTest:          false
        depthWrite:         false
        opacity:            0.2
        wireframeLinewidth: 2
      
    dir_text:  new THREE.MeshPhongMaterial  
        color:       0xffffff
        shading:     THREE.FlatShading
        transparent: true
        opacity:     1.0
        
    file_text: new THREE.MeshPhongMaterial 
        color:       0x8888ff
        shading:     THREE.FlatShading
        transparent: true
        opacity:     1.0
        
    outline:   new THREE.ShaderMaterial 
        transparent: true,
        vertexShader: """
        varying vec3 vnormal;
        void main(){
            vnormal = normalize( mat3( modelViewMatrix[0].xyz, modelViewMatrix[1].xyz, modelViewMatrix[2].xyz ) * normal );
            gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
        }
        """
        fragmentShader: """
        varying vec3 vnormal;
        void main(){
            float z = abs(vnormal.z);
            gl_FragColor = vec4( 1,1,1, (1.0-z)*(1.0-z)/2.0 );
        }
        """

###
000       0000000    0000000   0000000    00000000  0000000  
000      000   000  000   000  000   000  000       000   000
000      000   000  000000000  000   000  0000000   000   000
000      000   000  000   000  000   000  000       000   000
0000000   0000000   000   000  0000000    00000000  0000000  
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

document.observe 'dom:loaded', ->
    
    knix.init
        console: 'shade'
        
    initMenu()
        
    scene = new (THREE.Scene)

    dolly = new Dolly
        scale: 0.16
    
    renderer = new THREE.WebGLRenderer 
        antialias: true
        
    renderer.setSize window.innerWidth, window.innerHeight
    renderer.setClearColor color.background
    renderer.sortObjects = false
    renderer.autoClear = true
    document.body.appendChild renderer.domElement

    sun = new THREE.DirectionalLight color.sun
    sun.position.set -.3, .8, 1
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
            doWalk selected.node.path
        else 
            doWalk nodes.rootDir + '/..'
        
    window.addEventListener 'dblclick',  onDoubleClick
    window.addEventListener 'mousemove',   onMouseMove
    window.addEventListener 'resize',   onWindowResize
            
    anim()
    # nodes = new Balls material
    nodes = new Boxes material
    doWalk rootDir    
    
toggleNodes = () ->
    rootDir = nodes.rootDir
    nodes.clear()
    if nodes.constructor.name == 'Balls'
        nodes = new Boxes material
    else
        nodes = new Balls material
    doWalk rootDir 
    
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
    raycaster.setFromCamera mouse, dolly.camera
    intersects = raycaster.intersectObjects scene.children   
    selected = undefined
    text?.remove()
    if intersects.length
        selected = intersects[intersects.length-1].object
        if selected == outline
            selected = intersects[intersects.length-2].object
        return if outline?.name == selected.node.name
        if outline?
            outline.prt.remove outline
            outline = null
        if selected.node.name != '.'
            outline = new THREE.Mesh selected.geometry, material.outline
            outline.name = selected.node.name
            outline.prt = selected
            selected.add outline
            needsRender = true
            nodes.refreshNodeText selected.node
            console.log selected.node.scale

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
