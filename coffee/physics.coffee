
# 00000000   000   000  000   000   0000000  000   0000000   0000000  
# 000   000  000   000   000 000   000       000  000       000       
# 00000000   000000000    00000    0000000   000  000       0000000   
# 000        000   000     000          000  000  000            000  
# 000        000   000     000     0000000   000   0000000  0000000   

{ first, pos, log, $, _ } = require 'kxk'

window.decomp = require 'poly-decomp'
Matter = require 'matter-js'

class Physics

    constructor: (@element) ->

        @engine = Matter.Engine.create()
        @engine.timing.timeScale = 1
        
        @world = @engine.world
        @world.gravity.y = 0
                
        br = @element.getBoundingClientRect()
        
        window.requestAnimationFrame @onRender
        
        @itemBodies = []
        
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
        
        chevron = Matter.Vertices.fromPath '100 0 75 50 100 100 25 100 0 50 25 0'

        stack = Matter.Composites.stack 50, 50, 3, 3, 100, 100, (x, y) ->
            color = Matter.Common.choose ['#556270', '#4ECDC4', '#C7F464', '#FF6B6B', '#C44D58']
            Matter.Bodies.fromVertices x, y, chevron, 
                render:
                    fillStyle:   color,
                    strokeStyle: color,
                    lineWidth:   1
                frictionStatic:  0
                frictionAir:     0
                friction:        0
                density:         1000
                restitution:     0.5
            , true

        Matter.World.add @world, stack

        mouse = Matter.Mouse.create @render.canvas
        mouseConstraint = Matter.MouseConstraint.create @engine, 
            mouse: mouse,
            constraint: 
                stiffness: 0.2,
                render: 
                    visible: true

        Matter.World.add @world, mouseConstraint
        
        Matter.Render.run @render            
        @debug = true

        @shipAngle = 0
        @shipThrust = 0
        
        @render.mouse = mouse
        @render.canvas.style.background = 'transparent'
        @render.canvas.style.position   = 'absolute'
         
        Matter.Runner.run @runner, @engine            
        
        @setBounds br.width, br.height
       
    onTick: (event) =>

        ship = @itemBodies[0][1]
        dir = pos(0,-1).rotate ship.angle*180.0/Math.PI
        ship.applyForce dir.times @shipThrust * 300
        ship.addAngle @shipAngle/10
        
    onRender: (time) =>

        for [item, body] in @itemBodies
            
            item.translate 0, 0
            item.rotate body.angle*180.0/Math.PI
            item.translate body.position.x, body.position.y
            
        window.requestAnimationFrame @onRender
        
    addItem: (item, opt) ->
        
        vertices = @verticesForItem first item.children()
        color = '#88f'
        body = Matter.Bodies.fromVertices 0, 0, vertices,
                render:
                    fillStyle:   'none',
                    strokeStyle: color,
                    lineWidth:   1
                frictionStatic:  0
                frictionAir:     0
                friction:        0
                density:         1000
                restitution:     0.5
                
        if body
            
            dx = (body.bounds.min.x + body.bounds.max.x)/2
            dy = (body.bounds.min.y + body.bounds.max.y)/2
            
            for child in item.children()
                child.transform x:dx, y:dy, relative: true
            
            @itemBodies.push [item, body]
            Matter.World.add @world, body
            
            Matter.Body.setPosition body, x:(opt?.x ? 0), y:(opt?.y ? 0)
            
            body.applyForce = (force) -> Matter.Body.applyForce @, @position, force
            body.addAngularVelocity = (value) -> Matter.Body.setAngularVelocity @, @.angularVelocity + value
            body.addAngle = (value) -> 
                Matter.Body.setAngle @, @.angle + value
                Matter.Body.setAngularVelocity @, 0
            
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
            
        positions.pop()
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

    posForPoint: (point) ->
                
        switch point[0]
            when 'C'      then pos point[5], point[6]
            when 'S', 'Q' then pos point[3], point[4]
            when 'M', 'L' then pos point[1], point[2]
            else               pos point[0], point[1]
        
    # 0000000    00000000  0000000    000   000   0000000   
    # 000   000  000       000   000  000   000  000        
    # 000   000  0000000   0000000    000   000  000  0000  
    # 000   000  000       000   000  000   000  000   000  
    # 0000000    00000000  0000000     0000000    0000000   
    
    showDebug: (show=true) ->
        
        if show and not @debug
            @debug = true
            log 'run'
            Matter.Render.run @render  
            @render.canvas.style.display = 'block'
        else if not show and @debug
            @debug = false
            log 'stop'
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
