
class Dolly

    constructor: (config) -> 
        @target      = new THREE.Vector3()
        @perspective = config.perspective or false
        @maxDist     = config.maxDist or Infinity
        @minDist     = config.minDist or 0
        @needsRender = false

        if @perspective
            @camera = new THREE.PerspectiveCamera 75, window.innerWidth / window.innerHeight, 0.001, 200
        else
            @camera = new THREE.OrthographicCamera window.innerWidth/-2, window.innerWidth/2, window.innerHeight/2, window.innerHeight/-2, 0.001, 200
        @camera.position.z = @maxDist        
        @scale = 1
        @pivot = 0

        window.addEventListener 'mousewheel', @onMouseWheel
        window.addEventListener 'mousedown',  @onMouseDown
        window.addEventListener 'mousemove',  @onMouseMove        
        window.addEventListener 'mouseup',    @onMouseUp

    onMouseDown:  (event) => 
        @mouseX = event.clientX
        @mouseY = event.clientY
        window.addEventListener 'mousemove',  @onPivotMove 
        window.removeEventListener 'mousemove',  @onMouseMove    
        @isPivoting = true    
        
    onMouseUp:    (event) => 
        window.removeEventListener 'mousemove',  @onPivotMove 
        window.addEventListener 'mousemove',  @onMouseMove  
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
        @needsRender = true
        
    addHeight: (factor) =>
        @target.y -= factor
        @camera.position.y -= factor
        
    addPivot: (factor) =>
        targetToCam = @camera.position.clone().sub @target
        targetToCam.applyEuler new THREE.Euler(0, factor, 0)
        @camera.position.copy @target.clone().add targetToCam
        @camera.lookAt @target
        @camera.updateProjectionMatrix()

    onMouseWheel: (event) => @zoom 1-event.wheelDelta/10000
        
    zoom: (factor) =>
        if @perspective
            targetToCam = @camera.position.sub @target
            targetToCam.setLength Math.max(@minDist, Math.min(@maxDist, targetToCam.length()*factor))
            @camera.position = @target.clone().add targetToCam
        else
            mouseYFactor = @mouseY / window.innerHeight
            mouseYPos = @camera.top - mouseYFactor * (@camera.top - @camera.bottom)
            # dbg mouseYFactor, mouseYPos
            @scale *= factor
            @scale = 1 if @scale > 1
            @scale = 0.000001 if @scale < 0.000001
            w = window.innerWidth * @scale
            h = window.innerHeight * @scale
                        
            @camera.left   = w/-2
            @camera.right  = w/2
            @camera.top = mouseYPos + mouseYFactor * h
            @camera.bottom = @camera.top - h
            
        @camera.updateProjectionMatrix()
        @needsRender = true
        
module.exports = Dolly
