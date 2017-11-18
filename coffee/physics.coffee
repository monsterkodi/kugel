
# 00000000   000   000  000   000   0000000  000   0000000   0000000  
# 000   000  000   000   000 000   000       000  000       000       
# 00000000   000000000    00000    0000000   000  000       0000000   
# 000        000   000     000          000  000  000            000  
# 000        000   000     000     0000000   000   0000000  0000000   

{ deg2rad, rad2deg, clamp, first, pos, sw, sh, log, $, _ } = require 'kxk'

window.decomp = require 'poly-decomp'
Matter        = require 'matter-js'
svg           = require './svg'

class Physics

    constructor: (@kugel, @element) ->

        @engine = Matter.Engine.create()
        @engine.timing.timeScale = 1
        @engine.timing.isFixed = true
        
        @world = @engine.world
        @world.gravity.y = 0

        br = @element.getBoundingClientRect()
        
        @bodies = []
        
        @render = Matter.Render.create
            element: @element
            engine: @engine
            options:
                wireframes:     false
                showPositions:  true
                showVelcity:    false
                showCollisions: true
                showBounds:     false
                width:          sw()
                height:         sh()
                hasBounds:      true

        @runner = Matter.Runner.create delta:1000/60, isFixed:false
        
        Matter.Events.on @runner, 'beforeTick', @onBeforeTick 
        Matter.Events.on @runner, 'afterTick',  @onAfterTick 

        Matter.World.add @world , []
        
        mouse = Matter.Mouse.create @render.canvas
        mouseConstraint = Matter.MouseConstraint.create @engine, 
            mouse: mouse,
            constraint: 
                stiffness: 0.2,
                render: 
                    visible: true

        Matter.World.add @world, mouseConstraint
        
        @debug = false
        if @debug then Matter.Render.run @render            
        
        @render.mouse = mouse
        @render.canvas.style.position = 'absolute'
        @render.canvas.style.top     = 0
        @render.canvas.style.left    = 0
        @render.canvas.style.width   = '100%'
        @render.canvas.style.height  = '100%'
        @render.canvas.style.display = 'none'
         
        Matter.Runner.run @runner, @engine            
        
        @zoom = 1
        @setViewSize br.width, br.height
        
       
    # 000000000  000   0000000  000   000  
    #    000     000  000       000  000   
    #    000     000  000       0000000    
    #    000     000  000       000  000   
    #    000     000   0000000  000   000  
    
    onBeforeTick: (tick) =>
        
        @kugel.beforeTick tick.source.delta
        
    onAfterTick: (tick) =>
        
        @kugel.afterTick tick.source.delta
        
        for body in @bodies
            item = body.item
            inside = Matter.Bounds.overlaps @render.bounds, body.bounds
            if inside
                item.show() if not item.visible()
            else
                item.hide() if item.visible()
                
            continue if not inside or body.isStatic
            
            if not isNaN body.angle
                if body.angle != deg2rad item.transform().rotation
                    item.rotate 0
                    item.translate 0, 0
                    item.rotate rad2deg body.angle
            else 
                log 'isNaN', body.name
            if body.velocity.x != 0 or body.velocity.y != 0
                item.translate body.position.x, body.position.y            

        if @kugel.pad.axes?[3]
            @setZoom @zoom * (1+@kugel.pad.axes[3]/75)
        else
            @kugel.onResize()
                        
    #  0000000   0000000    0000000          0000000     0000000   0000000    000   000  
    # 000   000  000   000  000   000        000   000  000   000  000   000   000 000   
    # 000000000  000   000  000   000        0000000    000   000  000   000    00000    
    # 000   000  000   000  000   000        000   000  000   000  000   000     000     
    # 000   000  0000000    0000000          0000000     0000000   0000000       000     
    
    addBody: (name, position, opt) ->
        
        opt ?= {}
        
        body = svg.cloneBody name, @kugel.svg.defs()
        
        item = body.item
        @kugel.svg.add item
        
        @bodies.push body
        Matter.World.add @world, body
        
        body.applyForce  = (value) -> Matter.Body.applyForce  @, @position, value
        body.setVelocity = (value) -> Matter.Body.setVelocity @, value
        body.setStatic   = (value) -> Matter.Body.setStatic   @, value
        body.setDensity  = (value) -> Matter.Body.setDensity  @, value
        body.setPosition = (value) -> Matter.Body.setPosition @, value
        body.setAngle    = (value) -> Matter.Body.setAngle    @, value
        body.setAngularVelocity = (value) -> Matter.Body.setAngularVelocity @, value
        body.addAngularVelocity = (value) -> Matter.Body.setAngularVelocity @, @.angularVelocity + value
        body.addAngle = (value) -> 
            Matter.Body.setAngle @, @angle + value
            Matter.Body.setAngularVelocity @, 0
            
        body.setPosition position
        
        body.setStatic true if opt.static
        if opt.angle?
            body.setAngle deg2rad opt.angle 
            item.rotate opt.angle
        item.translate body.position.x, body.position.y            
        
        body
                
    # 0000000    00000000  0000000    000   000   0000000   
    # 000   000  000       000   000  000   000  000        
    # 000   000  0000000   0000000    000   000  000  0000  
    # 000   000  000       000   000  000   000  000   000  
    # 0000000    00000000  0000000     0000000    0000000   
    
    toggleDebug: -> @showDebug not @debug
    
    showDebug: (show=true) ->
        
        if show and not @debug
            @debug = true
            Matter.Render.run @render  
            @render.canvas.style.display = 'block'
            @render.canvas.style.background = 'rgba(0,0,0,0)'
        else if not show and @debug
            @debug = false
            Matter.Render.stop @render  
            @render.canvas.style.display = 'none'
        
    # 0000000     0000000   000   000  000   000  0000000     0000000  
    # 000   000  000   000  000   000  0000  000  000   000  000       
    # 0000000    000   000  000   000  000 0 000  000   000  0000000   
    # 000   000  000   000  000   000  000  0000  000   000       000  
    # 0000000     0000000    0000000   000   000  0000000    0000000   
    
    zoomIn:  -> @setZoom clamp 1, 5, @zoom - 1
    zoomOut: -> 
        if @zoom < 1 then @setZoom 1
        else @setZoom clamp 1, 5, @zoom + 1

    setZoom: (@zoom) ->
        @zoom = clamp 0.25, 5, @zoom
        w = @render.canvas.width  * @zoom
        h = @render.canvas.height * @zoom
        if @kugel.ship?
            x = @kugel.ship.body.position.x - w/2
            y = @kugel.ship.body.position.y - h/2
        else
            x = - w/2
            y = - h/2
        vertices = Matter.Vertices.fromPath "#{x} #{y} #{x+w} #{y} #{x+w} #{y+h} #{x} #{y+h}"
        Matter.Bounds.update @render.bounds, vertices, 0
    
        @kugel.setViewBox x, y, w, h
        
    setViewSize: (w,h) ->
        
        @render.canvas.width  = w
        @render.canvas.height = h
        
        @setZoom @zoom
        
module.exports = Physics
