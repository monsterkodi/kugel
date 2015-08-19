###
000000000  00000000   000   000   0000000  000   000
   000     000   000  000   000  000       000  000 
   000     0000000    000   000  000       0000000  
   000     000   000  000   000  000       000  000 
   000     000   000   0000000    0000000  000   000
###

tools   = require './knix/tools'
color   = require './color'
log     = require './knix/log'
Vect    = require './vect'
Quat    = require './quat'
vec     = Vect.new
clamp   = tools.clamp
deg2rad = tools.deg2rad

class Truck

    constructor: (config={}) -> 
        @target  = vec()
        fov      = config.fov or 60
        far      = config.far or 1000
        near     = config.near or 0.001
        @dist    = config.dist or 300
        @maxDist = config.maxDist or 600
        @minDist = config.minDist or 0.001
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
            
    updateSun: () => @sun.position.copy @camera.position
    # updateSun: () =>
            
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
        diff = vec()
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
                
        # if event.shiftKey or event.altKey or event.ctrlKey or event.metaKey
        q = @camera.quaternion.clone()
        q.multiply Quat.axis(vec(1,0,0), deltaY*0.2)
        q.multiply Quat.axis(vec(0,1,0), deltaX*0.1)
        @setQuat q
        
    distFactor: () => (@dist - @minDist) / (@maxDist - @minDist)
        
    setQuat: (quat) =>
        dist = @camera.position.distanceTo @target
        
        camUp  = vec(0,1,0)
        camPos = vec(0,0,1)
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
