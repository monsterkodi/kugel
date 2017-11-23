
# 00000000   000   000  000   000   0000000  000   0000000   0000000  
# 000   000  000   000   000 000   000       000  000       000       
# 00000000   000000000    00000    0000000   000  000       0000000   
# 000        000   000     000          000  000  000            000  
# 000        000   000     000     0000000   000   0000000  0000000   

{ deg2rad, rad2deg, post, clamp, first, pos, sw, sh, log, $, _ } = require 'kxk'

{ profile } = require './utils'

window.decomp = require 'poly-decomp'
Matter        = require 'matter-js'
svg           = require './svg'

class Physics

    constructor: (@world, @element) ->

        @pad    = @world.pad
        @engine = Matter.Engine.create()
        @engine.timing.timeScale = 1
        @engine.timing.isFixed = true
        
        @engine.world.gravity.y = 0
        @center = pos 0,0

        br = @element.getBoundingClientRect()
        
        @bodies = []
        
        @pad = @world.pad
        
        @render = Matter.Render.create
            element: @element
            engine: @engine
            options:
                wireframes:     false
                showBounds:     false
                showVelocity:   true
                showPositions:  true
                showCollisions: true
                hasBounds:      true
                width:          sw()
                height:         sh()

        @runner = Matter.Runner.create delta:1000/60, isFixed:false
        
        Matter.Events.on @engine, 'beforeUpdate', @onBeforeUpdate
        Matter.Events.on @runner, 'beforeTick',   @onBeforeTick 
        Matter.Events.on @runner, 'afterTick',    @onAfterTick 

        Matter.World.add @engine.world, []
        
        mouse = Matter.Mouse.create @render.canvas
        mouseConstraint = Matter.MouseConstraint.create @engine, 
            mouse: mouse,
            constraint: 
                stiffness: 0.2,
                render: 
                    visible: true

        Matter.World.add @engine.world, mouseConstraint
        
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

    onBeforeUpdate: =>
        
        @world.beforeUpdate?()
    
    onBeforeTick: (tick) =>
        
        if @pad.button('pad').down then @toggleDebug()
        if @pad.button('up').down then @zoomIn()
        if @pad.button('down').down then @zoomOut()
        if @pad.button('options').down then post.toMain 'reloadWin'
        
        @world.beforeTick tick.source.delta
        
    onAfterTick: (tick) =>
        
        if @pad.axes?[3]
            @setZoom @zoom * (1+@pad.axes[3]/75)
        else
            @world.onResize()

        @world.afterTick tick.source.delta

        for body in @bodies.filter((b) -> b.lifetime)

            body.lifetime -= tick.source.delta
            if body.lifetime <= 0
                @delBody body
            else 
                body.tick?(tick.source.delta)
        
        @world.draw()
                                                        
    #  0000000   0000000    0000000          0000000     0000000   0000000    000   000  
    # 000   000  000   000  000   000        000   000  000   000  000   000   000 000   
    # 000000000  000   000  000   000        0000000    000   000  000   000    00000    
    # 000   000  000   000  000   000        000   000  000   000  000   000     000     
    # 000   000  0000000    0000000          0000000     0000000   0000000       000     
    
    addBody: (name, opt) ->
        
        opt ?= {}
        
        body = svg.cloneBody name, opt
        
        @bodies.push body
        Matter.World.add @engine.world, body
        
        body.applyForce  = (value) -> Matter.Body.applyForce  @, @position, value
        body.setVelocity = (value) -> Matter.Body.setVelocity @, value
        body.setStatic   = (value) -> Matter.Body.setStatic   @, value
        body.setDensity  = (value) -> Matter.Body.setDensity  @, value
        body.setMass     = (value) -> Matter.Body.setMass     @, value
        body.setPosition = (value) -> Matter.Body.setPosition @, value
        body.setAngle    = (value) -> Matter.Body.setAngle    @, value
        body.setAngularVelocity = (value) -> Matter.Body.setAngularVelocity @, value
        body.addAngularVelocity = (value) -> Matter.Body.setAngularVelocity @, @.angularVelocity + value
        body.addAngle = (value) -> 
            Matter.Body.setAngle @, @angle + value
            Matter.Body.setAngularVelocity @, 0
            
        body.setPosition pos opt.x ? 0, opt.y ? 0
        
        body.setStatic true if opt.static
        
        body.setAngle deg2rad(opt.angle) if _.isNumber opt.angle
        body.scale   = opt.scale   if _.isNumber opt.scale
        body.opacity = opt.opacity if _.isNumber opt.opacity
        
        body
        
    delBody: (body) ->
        
        _.pull @bodies, body
        Matter.Composite.remove @engine.world, body
        
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
        
        @zoom = clamp 0.2, 5, @zoom
        w = @render.canvas.width  * @zoom
        h = @render.canvas.height * @zoom
        x = @center.x - w/2
        y = @center.y - h/2

        vertices = Matter.Vertices.fromPath "#{x} #{y} #{x+w} #{y} #{x+w} #{y+h} #{x} #{y+h}"
        Matter.Bounds.update @render.bounds, vertices, 0
    
    setViewSize: (w,h) ->
        
        @render.canvas.width  = w
        @render.canvas.height = h
        
        @world.canvas.width   = w
        @world.canvas.height  = h
        
        @setZoom @zoom
        
module.exports = Physics
