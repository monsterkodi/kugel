tools   = require './knix/tools'
color   = require './color'
clamp   = tools.clamp
deg2rad = tools.deg2rad

class Truck

    constructor: (config={}) -> 
        @target  = new THREE.Vector3()
        fov      = config.fov or 60
        far      = config.far or 1000
        near     = config.near or 0.001
        @dist    = config.dist or 300
        @maxDist = config.maxDist or 300
        @minDist = config.minDist or 0.001
        @yaw     = config.yaw or 0
        @minAlti = -90
        @maxAlti = 90
        @alti    = 0
        @azim    = 0
        aspect   = window.innerWidth / window.innerHeight

        @camera = new THREE.PerspectiveCamera fov, aspect, near, far
        @camera.position.z = @dist

        window.addEventListener 'mousewheel', @onMouseWheel
        window.addEventListener 'mousedown',  @onMouseDown
        window.addEventListener 'mousemove',  @onMouseMove
        window.addEventListener 'mouseup',    @onMouseUp
        window.addEventListener 'keypress',   @onKeyPress
        window.addEventListener 'keyrelease', @onKeyRelease

        @sun = new THREE.PointLight color.sun
        @sun.position.copy @camera.position
        scene.add @sun
        
        ambient = new THREE.AmbientLight color.ambient
        scene.add ambient
        
        @sun.position.copy @camera.position
            
    # updateSun: () => @sun.position.copy @camera.position
    updateSun: () =>
            
    remove: () =>
        window.removeEventListener 'mousewheel', @onMouseWheel
        window.removeEventListener 'mousedown',  @onMouseDown
        window.removeEventListener 'mousemove',  @onMouseDrag 
        window.removeEventListener 'mousemove',  @onMouseMove        
        window.removeEventListener 'mouseup',    @onMouseUp
        window.removeEventListener 'keypress',   @onKeyPress
        window.removeEventListener 'keyrelease', @onKeyRelease
        scene.remove @sun
        @camera = null

    moveToTargetAnim: () =>
        @setTarget @target.clone().lerp @moveTarget, 0.1 + @distFactor() * 0.1
        if @target.distanceTo(@moveTarget) > 0.001 + 0.01 * @distFactor()
            requestAnimationFrame @moveToTargetAnim
        else 
            @setTarget @moveTarget
            @moveTarget = null
            clog "movedToTarget"

    moveToTarget: (target) =>
        @moveTarget = target
        requestAnimationFrame @moveToTargetAnim

    setTarget: (target) =>
        diff = new THREE.Vector3()
        diff.copy target
        diff.sub @target
        @target.copy target
        @camera.position.add diff
        @updateSun()

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
        
    distFactor: () => (@dist - @minDist) / (@maxDist - @minDist)
        
    move: (x, y) =>
        f = 0.001 + 0.1*@distFactor()
        
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
        @updateSun()

    pivot: (x, y) => @setAzimAlti @azim+x, clamp @minAlti, @maxAlti, @alti+y
        
    setAzimAlti: (azim, alti) =>
        
        @alti = alti
        @azim = azim
        
        dist = @camera.position.distanceTo @target
        
        camUp  = new THREE.Vector3(0,1,0)
        camPos = new THREE.Vector3(0,0,1)
        yaw = deg2rad @azim
        pitch = deg2rad @alti
        camUp.applyAxisAngle  new THREE.Vector3(1,0,0), pitch
        camPos.applyAxisAngle new THREE.Vector3(1,0,0), pitch
        camUp.applyAxisAngle  new THREE.Vector3(0,1,0), yaw
        camPos.applyAxisAngle new THREE.Vector3(0,1,0), yaw
        
        camPos.multiplyScalar dist
        camPos.add @target
        @camera.position.copy camPos
        @camera.up.copy camUp
        @camera.lookAt @target
        @updateSun()
    
    setQuat: (quat) =>
        dist = @camera.position.distanceTo @target
        
        camUp  = new THREE.Vector3(0,1,0)
        camPos = new THREE.Vector3(0,0,1)
        camUp.applyQuaternion quat
        camPos.applyQuaternion quat
        
        camPos.multiplyScalar dist
        camPos.add @target
        @camera.position.copy camPos
        @camera.up.copy camUp
        @camera.lookAt @target
        @updateSun()
        
                
    onMouseWheel: (event) => @zoom 1-event.wheelDelta/20000
        
    zoom: (factor) =>
        camPos = @camera.position.clone()
        camPos.sub @target
        camPos.multiplyScalar factor
        @dist = camPos.length()
        if @dist > @maxDist
            camPos.normalize().multiplyScalar @maxDist
            @dist = @maxDist
        if @dist < @minDist
            camPos.normalize().multiplyScalar @minDist
            @dist = @minDist
        camPos.add @target
        @camera.position.copy camPos
        @updateSun()
        
module.exports = Truck
