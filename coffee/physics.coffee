
# 00000000   000   000  000   000   0000000  000   0000000   0000000  
# 000   000  000   000   000 000   000       000  000       000       
# 00000000   000000000    00000    0000000   000  000       0000000   
# 000        000   000     000          000  000  000            000  
# 000        000   000     000     0000000   000   0000000  0000000   

{ deg2rad, rad2deg, clamp, first, pos, sw, sh, log, $, _ } = require 'kxk'

{ profile } = require './utils'

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
                showBounds:     false
                showVelocity:   true
                showPositions:  true
                showCollisions: true
                hasBounds:      true
                width:          sw()
                height:         sh()

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
        
        if @kugel.pad.axes?[3]
            @setZoom @zoom * (1+@kugel.pad.axes[3]/75)
        else
            @kugel.onResize()

        @kugel.afterTick tick.source.delta
        
        @draw()

    draw: ->
        
        w = sw()
        h = sh()
        
        size  = pos @render.bounds.max.x - @render.bounds.min.x, @render.bounds.max.y - @render.bounds.min.y
        scale = pos w/size.x, h/size.y

        shipx = @kugel.ship.body.position.x
        shipy = @kugel.ship.body.position.y
        
        @kugel.ctx.fillStyle = '#002'
        @kugel.ctx.fillRect 0,0,w,h
        
        @kugel.stars.draw()
        @kugel.ship.draw size, scale, w, h
        
        for body in @bodies

            if body.image

                @kugel.ctx.save()
                x = (size.x/2 + body.position.x - shipx)/@zoom
                y = (size.y/2 + body.position.y - shipy)/@zoom    
                @kugel.ctx.translate x, y
                @kugel.ctx.rotate body.angle
                @kugel.ctx.scale scale.x, scale.y
                @kugel.ctx.drawImage body.image.image, -body.image.image.width/2 + body.image.offset.x, -body.image.image.height/2 + body.image.offset.y
                @kugel.ctx.restore()
                                        
    #  0000000   0000000    0000000          0000000     0000000   0000000    000   000  
    # 000   000  000   000  000   000        000   000  000   000  000   000   000 000   
    # 000000000  000   000  000   000        0000000    000   000  000   000    00000    
    # 000   000  000   000  000   000        000   000  000   000  000   000     000     
    # 000   000  0000000    0000000          0000000     0000000   0000000       000     
    
    addBody: (name, position, opt) ->
        
        opt ?= {}
        
        body = svg.cloneBody name
        
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
        
        body
        
    delBody: (body) ->
        
        _.pull @bodies, body
        Matter.Composite.remove @world, body
        
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
        if @kugel.ship?
            x = @kugel.ship.body.position.x - w/2
            y = @kugel.ship.body.position.y - h/2
        else
            x = - w/2
            y = - h/2
        vertices = Matter.Vertices.fromPath "#{x} #{y} #{x+w} #{y} #{x+w} #{y+h} #{x} #{y+h}"
        Matter.Bounds.update @render.bounds, vertices, 0
    
    setViewSize: (w,h) ->
        
        @render.canvas.width  = w
        @render.canvas.height = h
        
        @kugel.canvas.width   = w
        @kugel.canvas.height  = h
        
        @setZoom @zoom
        
module.exports = Physics
