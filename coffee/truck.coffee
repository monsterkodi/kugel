tools = require './knix/tools'
clamp = tools.clamp

class Truck

    constructor: (config={}) -> 
        @target   = new THREE.Vector3()
        fov       = config.fov or 60
        far       = config.far or 1000
        near      = config.near or 0.001
        @dist     = config.dist or 100
        @maxDist  = config.maxDist or 200
        @minDist  = config.minDist or 0.001
        @yaw      = config.yaw or 0
        @altitude = Math.PI/2
        @azimuth  = 0
        aspect    = window.innerWidth / window.innerHeight

        @camera = new THREE.PerspectiveCamera fov, aspect, near, far
        @camera.position.z = @dist

        window.addEventListener 'mousewheel', @onMouseWheel
        window.addEventListener 'mousedown',  @onMouseDown
        window.addEventListener 'mousemove',  @onMouseMove        
        window.addEventListener 'mouseup',    @onMouseUp
        window.addEventListener 'keypress',   @onKeyPress
        window.addEventListener 'keyrelease', @onKeyRelease

        @sun = new THREE.PointLight 0xffffff
        @sun.position.copy @camera.position
        scene.add @sun

    setTarget: (target) =>
        diff = new THREE.Vector3()
        diff.copy target
        diff.sub @target
        @target.copy target
        @camera.position.add diff
        @sun.position.copy @camera.position
        @camera.needsRender = true

    onKeyPress: (event) =>
    onKeyRelease: (event) =>

    onMouseDown: (event) => 
        @mouseX = event.clientX
        @mouseY = event.clientY
        window.addEventListener    'mousemove',  @onMouseDrag 
        window.removeEventListener 'mousemove',  @onMouseMove    
        @isPivoting = true    
        
    onMouseUp: (event) => 
        window.removeEventListener 'mousemove',  @onMouseDrag 
        window.addEventListener    'mousemove',  @onMouseMove  
        @isPivoting = false          
        
    onMouseMove:  (event) =>
        @mouseX = event.clientX
        @mouseY = event.clientY      
        
    onMouseDrag:  (event) =>
        deltaX = @mouseX-event.clientX
        deltaY = @mouseY-event.clientY
        @mouseX = event.clientX
        @mouseY = event.clientY
                
        if event.shiftKey or event.altKey or event.ctrlKey or event.metaKey
            @move deltaX, deltaY
        else
            @pivot deltaX/400.0, deltaY/200.0
        @camera.needsRender = true
        
    move: (x, y) =>
        f = (@dist - @minDist) / (@maxDist - @minDist)
        f = f*f*f*f*f
        
        right = new THREE.Vector3 1, 0 ,0
        right.applyMatrix4 @camera.matrixWorld
        right.sub @camera.position
        right.multiplyScalar x * f

        up = new THREE.Vector3 0, 1 ,0
        up.applyMatrix4 @camera.matrixWorld
        up.sub camera.position
        up.multiplyScalar -y * f
        
        @camera.position.add right
        @camera.position.add up
        @target.add right
        @target.add up
        @sun.position.copy @camera.position
        @camera.needsRender = true

    pivot: (x, y) =>
        
        @altitude = clamp 0, Math.PI/2, @altitude-y
        @azimuth  += x

        # clog @altitude, @azimuth, 180 * @altitude / Math.PI, 180 * @azimuth / Math.PI
        
        dist = @camera.position.distanceTo @target
        
        camUp = new THREE.Vector3(0,0,1)
        camPos = new THREE.Vector3(0,-1,0)
        camUp.applyAxisAngle new THREE.Vector3(1,0,0), -@altitude 
        camPos.applyAxisAngle new THREE.Vector3(1,0,0), -@altitude 
        camUp.applyAxisAngle new THREE.Vector3(0,0,1), @azimuth
        camPos.applyAxisAngle new THREE.Vector3(0,0,1), @azimuth
        
        camPos.multiplyScalar dist
        camPos.add @target
        @camera.position.copy camPos
        @camera.up.copy camUp
        @camera.lookAt @target
        @sun.position.copy @camera.position
        @camera.needsRender = true
                
    onMouseWheel: (event) => @zoom 1-event.wheelDelta/20000
        
    zoom: (factor) =>
        camPos = @camera.position.clone()
        camPos.sub @target
        camPos.multiplyScalar factor
        if camPos.length() > @maxDist
            camPos.normalize().multiplyScalar @maxDist
        if camPos.length() < @minDist
            camPos.normalize().multiplyScalar @minDist
        camPos.add @target
        @camera.position.copy camPos
        @sun.position.copy @camera.position
        @camera.needsRender = true
        
module.exports = Truck
