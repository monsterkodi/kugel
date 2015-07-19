
class Dolly

    constructor: (config={}) -> 
        @minScale    = config.minScale or 0.0001
        @target      = new THREE.Vector3()
        @scale       = config.scale or 0.16

        @camera = new THREE.OrthographicCamera(
            @scale*window.innerWidth/-2, 
            @scale*window.innerWidth/2, 
            @scale*window.innerHeight/2, 
            @scale*window.innerHeight/-2, 
            @minScale, 200)
        @camera.position.z = 100

        window.addEventListener 'mousewheel', @onMouseWheel
        window.addEventListener 'mousedown',  @onMouseDown
        window.addEventListener 'mousemove',  @onMouseMove        
        window.addEventListener 'mouseup',    @onMouseUp
        
        sun = new THREE.DirectionalLight 0xffffff
        sun.position.set -.3, .8, 1
        scene.add sun
        
    remove: () =>
        window.removeEventListener 'mousewheel', @onMouseWheel
        window.removeEventListener 'mousedown',  @onMouseDown
        window.removeEventListener 'mousemove',  @onPivotMove 
        window.removeEventListener 'mousemove',  @onMouseMove        
        window.removeEventListener 'mouseup',    @onMouseUp    
        scene.remove @sun    
        @camera = null

    onMouseDown:  (event) => 
        @mouseX = event.clientX
        @mouseY = event.clientY
        window.addEventListener    'mousemove',  @onPivotMove 
        window.removeEventListener 'mousemove',  @onMouseMove    
        @isPivoting = true    
        
    onMouseUp:    (event) => 
        window.removeEventListener 'mousemove',  @onPivotMove 
        window.addEventListener    'mousemove',  @onMouseMove  
        @isPivoting = false          
        
    onMouseMove:  (event) =>     
        @mouseX = event.clientX
        @mouseY = event.clientY        
        
    onPivotMove:  (event) => 
        deltaX = @mouseX-event.clientX
        deltaY = @mouseY-event.clientY
        @mouseX = event.clientX
        @mouseY = event.clientY        
        @addHeight deltaY*@scale
        @addPivot deltaX/200.0
        
    addHeight: (factor) =>
        @target.y -= factor
        @camera.position.y -= factor
        
    addPivot: (factor) =>
        targetToCam = @camera.position.clone().sub @target
        targetToCam.applyEuler new THREE.Euler(0, factor, 0)
        @camera.position.copy @target.clone().add targetToCam
        @camera.lookAt @target
        @camera.needsRender = true

    onMouseWheel: (event) => @zoom 1-event.wheelDelta/10000
        
    zoom: (factor) =>
        mouseYFactor = @mouseY / window.innerHeight
        mouseYPos = @camera.top - mouseYFactor * (@camera.top - @camera.bottom)
        @scale *= factor
        @scale = 1 if @scale > 1
        @scale = @minScale if @scale < @minScale
        w = window.innerWidth * @scale
        h = window.innerHeight * @scale
        # console.log w, h, @scale
        @camera.left   = w/-2
        @camera.right  = w/2
        @camera.top = mouseYPos + mouseYFactor * h
        @camera.bottom = @camera.top - h     
        @camera.updateProjectionMatrix()       
        @camera.needsRender = true
        
module.exports = Dolly
