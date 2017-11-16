
# 00000000   000   000  000   000   0000000  000   0000000   0000000  
# 000   000  000   000   000 000   000       000  000       000       
# 00000000   000000000    00000    0000000   000  000       0000000   
# 000        000   000     000          000  000  000            000  
# 000        000   000     000     0000000   000   0000000  0000000   

{ deg2rad, rad2deg, first, pos, log, $, _ } = require 'kxk'

window.decomp = require 'poly-decomp'
Matter        = require 'matter-js'
svg           = require './svg'

class Physics

    constructor: (@kugel, @element) ->

        @engine = Matter.Engine.create()
        @engine.timing.timeScale = 1
        
        @world = @engine.world
        @world.gravity.y = 0
                
        br = @element.getBoundingClientRect()
        
        window.requestAnimationFrame @onRender
        
        @bodies = []
        
        @render = Matter.Render.create
            element: @element
            engine: @engine
            options:
                wireframes:     false
                showPositions:  true
                showVelcity:    true
                showCollisions: true
                showBounds:     true

        @runner = Matter.Runner.create()
        
        Matter.Events.on @runner, 'beforeTick', @onTick 

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
        @render.canvas.style.background = 'transparent'
        @render.canvas.style.position   = 'absolute'
         
        Matter.Runner.run @runner, @engine            
        
        @setBounds br.width, br.height
       
    onTick: (event) =>

        @kugel.onTick event
                
    onRender: (time) =>

        for body in @bodies
            item = body.item
            item.translate 0, 0
            if not isNaN body.angle
                # log 'angle', body.angle, 'deg', rad2deg body.angle
                item.rotate rad2deg body.angle
            else 
                log 'isNaN', body.name
            item.translate body.position.x, body.position.y
            
        window.requestAnimationFrame @onRender
        
    #  0000000   0000000    0000000          0000000     0000000   0000000    000   000  
    # 000   000  000   000  000   000        000   000  000   000  000   000   000 000   
    # 000000000  000   000  000   000        0000000    000   000  000   000    00000    
    # 000   000  000   000  000   000        000   000  000   000  000   000     000     
    # 000   000  0000000    0000000          0000000     0000000   0000000       000     
    
    addBody: (name, position, opt) ->
        
        opt ?= {}
        
        item = svg.add name, parent:@kugel.svg
            
        vertices = @verticesForItem first item.children()

        body = Matter.Bodies.fromVertices 0, 0, vertices,
                render:
                    fillStyle:   'none'
                    strokeStyle: '#88f'
                    lineWidth:   1
                frictionStatic:  0
                frictionAir:     0
                friction:        0
                density:         1
                restitution:     1
                
        if not body
            log 'no body?', name, opt
            return null 
            
        dx = (body.bounds.min.x + body.bounds.max.x)/2
        dy = (body.bounds.min.y + body.bounds.max.y)/2
        
        for child in item.children()
            child.transform x:dx, y:dy, relative: true
        
        body.item = item
        @bodies.push body
        Matter.World.add @world, body
        
        body.applyForce  = (value) -> Matter.Body.applyForce  @, @position, value
        body.setVelocity = (value) -> Matter.Body.setVelocity @, value
        body.setStatic   = (value) -> Matter.Body.setStatic   @, value
        body.setDensity  = (value) -> Matter.Body.setDensity  @, value
        body.setPosition = (value) -> Matter.Body.setPosition @, value
        body.setAngle    = (value) -> Matter.Body.setAngle    @, value
        body.setAnglularVelocity = (value) -> Matter.Body.setAngularVelocity @, value
        body.addAngularVelocity = (value) -> Matter.Body.setAngularVelocity @, @.angularVelocity + value
        body.addAngle = (value) -> 
            Matter.Body.setAngle @, @angle + value
            Matter.Body.setAngularVelocity @, 0
            
        body.setPosition position
        body.setStatic true if opt.static
        log 'opt.angle', name, opt.angle
        body.setAngle deg2rad opt.angle if opt.angle?
        body
        
    verticesForItem: (item) ->

        subdivisions = 3
        @points = item.array().valueOf()
        
        indexPoints = []
        for index,point of @points
            indexPoints.push [index, point]

        positions = []
        
        addPos = (p) => positions.push @transform item, p
        
        for [index, point] in indexPoints
            switch point[0]
                when 'S', 'Q', 'C'
                    if index > 0
                        for subdiv in [1..subdivisions]
                            addPos @deCasteljauPos index, point, subdiv/(subdivisions+1)
            addPos @posForPoint point
            
        positions.pop() if item.type != 'polygon'
        positions

    itemMatrix: (item) ->
        
        m = item.transform().matrix.clone()
        for ancestor in item.parents()
            m = ancestor.transform().matrix.multiply m            
        m
        
    transform: (item, p) ->
        
        pos new SVG.Point(p).transform @itemMatrix item
        
    index: (index) -> (@points.length + index) % @points.length
    
    posForPoint: (point) ->
                
        switch point[0]
            when 'C'      then pos point[5], point[6]
            when 'S', 'Q' then pos point[3], point[4]
            when 'M', 'L' then pos point[1], point[2]
            else               pos point[0], point[1]
    
    posAt: (index, dot='point') ->

        index = @index  index
        point = @points[index]

        switch dot
            when 'point' then @posForPoint point
            when 'ctrl1', 'ctrls', 'ctrlq' then pos point[1], point[2]
            when 'ctrl2'                   then pos point[3], point[4]
            when 'ctrlb'
                point = @pointAt index
                switch point[0]
                    when 'C' then @posAt index, 'ctrl2'
                    when 'S' then @posAt index, 'ctrls'
                    when 'Q' then @posAt index, 'ctrlq'
                    else          @posAt index
            when 'ctrlr'
                index = @points.length if index == 1
                prevp = @posAt index-1
                ctrlb = @posAt index-1, 'ctrlb'
                prevp.minus prevp.to ctrlb

            else
                log "Points.posAt -- unhandled dot? #{dot}"
                pos point[1], point[2]
        
    deCasteljauPos: (index, point, factor) ->
        
        thisp = @posAt index
        prevp = @posAt index-1
        
        switch point[0]
            when 'C'
                ctrl1 = @posAt index, 'ctrl1'
                ctrl2 = @posAt index, 'ctrl2'
            when 'Q'
                ctrl1 = @posAt index, 'ctrlq'
                ctrl2 = ctrl1
            when 'S'
                ctrl1 = @posAt index, 'ctrlr'
                ctrl2 = @posAt index, 'ctrls'

        p1 = prevp.interpolate ctrl1, factor
        p2 = ctrl1.interpolate ctrl2, factor
        p3 = ctrl2.interpolate thisp, factor
        
        p4 = p1.interpolate p2, factor
        p5 = p2.interpolate p3, factor
        p6 = p4.interpolate p5, factor
        
    # 0000000    00000000  0000000    000   000   0000000   
    # 000   000  000       000   000  000   000  000        
    # 000   000  0000000   0000000    000   000  000  0000  
    # 000   000  000       000   000  000   000  000   000  
    # 0000000    00000000  0000000     0000000    0000000   
    
    showDebug: (show=true) ->
        
        if show and not @debug
            @debug = true
            Matter.Render.run @render  
            @render.canvas.style.display = 'block'
        else if not show and @debug
            @debug = false
            Matter.Render.stop @render  
            @render.canvas.style.display = 'none'
        
    # 0000000     0000000   000   000  000   000  0000000     0000000  
    # 000   000  000   000  000   000  0000  000  000   000  000       
    # 0000000    000   000  000   000  000 0 000  000   000  0000000   
    # 000   000  000   000  000   000  000  0000  000   000       000  
    # 0000000     0000000    0000000   000   000  0000000    0000000   
    
    setBounds: (w,h) ->
        
        @render.canvas.width  = w
        @render.canvas.height = h
        
        x = y = 0
        bounds = Matter.Vertices.fromPath "#{x} #{y} #{x+w} #{y} #{x+w} #{y+h} #{x} #{y+h}"
        Matter.Bounds.update @render.bounds, bounds, 0
        
module.exports = Physics
