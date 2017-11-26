
# 000   000  000   000   0000000   00000000  000      
# 000  000   000   000  000        000       000      
# 0000000    000   000  000  0000  0000000   000      
# 000  000   000   000  000   000  000       000      
# 000   000   0000000    0000000   00000000  0000000  

{ rad2deg, deg2rad, keyinfo, stopEvent, elem, last, post, prefs, sw, sh, pos, log, $, _ } = require 'kxk'

Physics = require './physics'
Stars   = require './stars'
Planet  = require './planet'
Pad     = require './pad'
Car     = require './car'
rect    = require './rect'
SVG     = require 'svg.js'
Matter  = require 'matter-js'

class Kugel

    constructor: (element) ->

        prefs.init()
        
        @element =$ element
        
        @focus()
        
        @element.addEventListener 'keydown', @onKeyDown
        @element.addEventListener 'keyup',   @onKeyUp
                
        window.onresize = @onResize
        
        @pad = new Pad()       

        @canvas = elem 'canvas', id: 'stars'
        @canvas.style.position   = 'absolute'
        @canvas.style.background = '#005'
        @canvas.style.top  = '0'
        @canvas.style.left = '0'
        @element.appendChild @canvas
        @ctx = @canvas.getContext '2d'
        
        @stars   = new Stars   @, @canvas
        @physics = new Physics @, @element
        @car     = new Car     @
        
        @planets = []
        @planets.push new Planet @physics, planet:'surface2', center: pos 0, -8200
        @planets.push new Planet @physics, planet:'surface',  center: pos 0, 2200
        
        @planet = last @planets
                            
        @physics.addBody 'ball',     x:-100, y:-300, scale: 2,   frictionStatic: 2, friction: 0.1, density: 0.01
        @physics.addBody 'trio',     x:-300, y:-200, scale: 0.4, frictionStatic: 2, friction: 0.1, density: 0.01
        @physics.addBody 'trio',     x:-200, y:-200, scale: 0.6, frictionStatic: 2, friction: 0.1, density: 0.01
        @physics.addBody 'trio',     x:-100, y:-200, scale: 0.8, frictionStatic: 2, friction: 0.1, density: 0.01
        
        @physics.addBody 'pentagon', x: 300, y:-300, scale: 0.4, frictionStatic: 0.1, friction: 0.1, density: 0.01
        @physics.addBody 'pentagon', x: 400, y:-300, scale: 0.6, frictionStatic: 0.1, friction: 0.1, density: 0.01
        @physics.addBody 'pentagon', x: 500, y:-300, scale: 0.8, frictionStatic: 0.1, friction: 0.1, density: 0.01
        
        @onResize()
        
    # 000000000  000   0000000  000   000  
    #    000     000  000       000  000   
    #    000     000  000       0000000    
    #    000     000  000       000  000   
    #    000     000   0000000  000   000  
    
    beforeUpdate: ->
        
        maxGravity = 0
        for planet in @planets
            gravity = planet.gravityAt @car.body.position
            if gravity.length() > maxGravity
                @planet = planet
        
        for body in Matter.Composite.allBodies @physics.engine.world
            if not body.isStatic
                for planet in @planets
                    bodyToCenter = planet.gravityAt body.position
                    bodyToCenter.scale body.mass
                    body.force.x += bodyToCenter.x
                    body.force.y += bodyToCenter.y
    
    beforeTick: (delta) ->
        
        @pad.snapState()
        @car.beforeTick delta
        
    afterTick: (delta) ->
        
        @car.afterTick delta
        @physics.center = pos @car.body.position
       
    # 0000000    00000000    0000000   000   000  
    # 000   000  000   000  000   000  000 0 000  
    # 000   000  0000000    000000000  000000000  
    # 000   000  000   000  000   000  000   000  
    # 0000000    000   000  000   000  00     00  
    
    draw: ->
        
        w = sw()
        h = sh()
        
        b = @physics.render.bounds
        size  = pos b.max.x - b.min.x, b.max.y - b.min.y
        scale = pos w/size.x, h/size.y

        if @pad.button('menu').down
            @streaks = not @streaks
          
        if not @streaks
            @ctx.fillStyle = '#002'
            @ctx.fillRect 0, 0, w, h
        else
            @ctx.fillStyle = 'rgba(0,0,31,0.03)'
            @ctx.fillRect 0, 0, w, h
                    
        gravAngle = - @planet.center.to(@car.pos()).rotation(pos(0,-1))
        
        rct = rect w, h
        rct.sub pos w/2, h/2
        rct.scale @physics.zoom*1.02
        rct.rotate -gravAngle
            
        @ctx.save()
        
        @ctx.scale 1/@physics.zoom, 1/@physics.zoom
        @ctx.translate size.x/2, size.y/2
        @ctx.rotate deg2rad gravAngle
        
        if not @streaks
            @stars.draw rct, @physics.zoom, pos @car.body.velocity
        
        @ctx.translate -@physics.center.x, -@physics.center.y

        for planet in @planets
            planet.draw @ctx
        
        @car.draw()
        
        for body in @physics.bodies

            if body.image

                @ctx.save()
                @ctx.globalAlpha = body.opacity ? 1
                @ctx.translate body.position.x, body.position.y
                @ctx.rotate body.angle
                scale = _.isNumber(body.scale) and body.scale or 1
                @ctx.scale scale, scale
                @ctx.globalCompositeOperation = body.compOp if body.compOp?
                x = -body.image.image.width/2  + body.image.offset.x
                y = -body.image.image.height/2 + body.image.offset.y
                @ctx.drawImage body.image.image, x, y
                @ctx.restore()
        
        @ctx.restore()
                                    
    onResize: => @physics.setViewSize sw(), sh()

    # 000   000  00000000  000   000  
    # 000  000   000        000 000   
    # 0000000    0000000     00000    
    # 000  000   000          000     
    # 000   000  00000000     000     
    
    focus: -> @element.focus()
    
    onKeyDown: (event) =>
        
        {mod, key, combo, char} = keyinfo.forEvent event

    onKeyUp: (event) =>
        
        {mod, key, combo, char} = keyinfo.forEvent event
                        
module.exports = Kugel
