
# 00000000   000   000  000   000   0000000  000   0000000   0000000  
# 000   000  000   000   000 000   000       000  000       000       
# 00000000   000000000    00000    0000000   000  000       0000000   
# 000        000   000     000          000  000  000            000  
# 000        000   000     000     0000000   000   0000000  0000000   

{ log, $, _ } = require 'kxk'

Matter = require 'matter-js'

class Physics

    constructor: (@element) ->

        @engine = Matter.Engine.create()
        @engine.timing.timeScale = 1
        
        @world = @engine.world
        @world.gravity.y = 0
                
        br = @element.getBoundingClientRect()
        
        @render = Matter.Render.create
            element: @element
            engine: @engine
            options:
                wireframes:     false
                showPositions:  true
                showVelcity:    true
                showCollisions: true

        @runner = Matter.Runner.create()

        # @center = Matter.Bodies.rectangle br.width/2, br.height/2, 50, 50, isStatic:true
        # Matter.World.add @world , [@center]
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

        @render.mouse = mouse
        @render.canvas.style.background = 'transparent'
        @render.canvas.style.position   = 'absolute'
         
        Matter.Runner.run @runner, @engine            
        
        @setBounds br.width, br.height
            
    setBounds: (w,h) ->
        
        @render.canvas.width  = w
        @render.canvas.height = h
        
        # Matter.Body.setPosition @center, x:w/2, y:h/2
        x = y = 0
        bounds = Matter.Vertices.fromPath "#{x} #{y} #{x+w} #{y} #{x+w} #{y+h} #{x} #{y+h}"
        Matter.Bounds.update @render.bounds, bounds, 0
        
module.exports = Physics
