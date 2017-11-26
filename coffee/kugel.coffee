
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
Ship    = require './ship'
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
        
        @stars   = new Stars()
        @physics = new Physics @, @element
        @car     = new Car     @
        @ship    = new Ship    @
        @ship.hide()
        @vehicle = @car
        
        @planets = []
        @planets.push new Planet @physics, planet:'surface2', center: pos 0, -8200
        @planets.push new Planet @physics, planet:'surface',  center: pos 0, 2200
        
        @planet = last @planets
                            
        @physics.newBody 'ball',     x:-100, y:-300, scale: 2,   frictionStatic: 2, friction: 0.1, density: 0.01
        @physics.newBody 'trio',     x:-300, y:-200, scale: 0.4, frictionStatic: 2, friction: 0.1, density: 0.01
        @physics.newBody 'trio',     x:-200, y:-200, scale: 0.6, frictionStatic: 2, friction: 0.1, density: 0.01
        @physics.newBody 'trio',     x:-100, y:-200, scale: 0.8, frictionStatic: 2, friction: 0.1, density: 0.01
        
        @physics.newBody 'pentagon', x: 300, y:-300, scale: 0.4, frictionStatic: 0.1, friction: 0.1, density: 0.01
        @physics.newBody 'pentagon', x: 400, y:-300, scale: 0.6, frictionStatic: 0.1, friction: 0.1, density: 0.01
        @physics.newBody 'pentagon', x: 500, y:-300, scale: 0.8, frictionStatic: 0.1, friction: 0.1, density: 0.01
        
        @onResize()
        
    # 000000000  000   0000000  000   000  
    #    000     000  000       000  000   
    #    000     000  000       0000000    
    #    000     000  000       000  000   
    #    000     000   0000000  000   000  
    
    beforeUpdate: ->
        
        maxGravity = 0
        for planet in @planets
            gravity = planet.gravityAt @vehicle.body.position
            if gravity.length() > maxGravity
                maxGravity = gravity.length()
                @planet = planet
                
        if maxGravity == 0 then @setVehicle @ship
        else                    @setVehicle @car
        
        for body in Matter.Composite.allBodies @physics.engine.world
            if not body.isStatic
                for planet in @planets
                    bodyToCenter = planet.gravityAt body.position
                    bodyToCenter.scale body.mass
                    body.force.x += bodyToCenter.x
                    body.force.y += bodyToCenter.y
    
    beforeTick: (delta) ->
        
        @pad.snapState()
        @vehicle.beforeTick delta
        
    afterTick: (delta) ->
        
        @vehicle.afterTick delta
        @physics.center = pos @vehicle.body.position
      
    setVehicle: (vehicle) ->
        
        if vehicle != @vehicle
            oldVehicle = @vehicle
            velocity = _.clone @vehicle.body.velocity
            angle    = @vehicle.body.angle
            angular  = @vehicle.body.angularVelocity
            oldVehicle.hide()
            @vehicle = vehicle
            @vehicle.show()
            @vehicle.setPos             oldVehicle.pos()
            @vehicle.body.setAngle      angle
            @vehicle.body.setVelocity   velocity
            # @vehicle.body.setAngularVelocity angular
            @vehicle.body.setAngularVelocity 0
        
    # 0000000    00000000    0000000   000   000  
    # 000   000  000   000  000   000  000 0 000  
    # 000   000  0000000    000000000  000000000  
    # 000   000  000   000  000   000  000   000  
    # 0000000    000   000  000   000  00     00  
    
    onZoom: -> @clear = true
    draw: ->
        
        w = sw()
        h = sh()
        
        b = @physics.render.bounds
        size  = pos b.max.x - b.min.x, b.max.y - b.min.y
        scale = pos w/size.x, h/size.y

        if @pad.button('menu').down then @streaks = not @streaks
          
        streaks = @streaks and not @clear
        @clear = false
        if streaks then @ctx.fillStyle = 'rgba(0,0,31,0.03)'
        else            @ctx.fillStyle = '#002'
        @ctx.fillRect 0, 0, w, h
               
        if @vehicle == @ship
            gravAngle = 0
        else
            gravAngle = - @planet.center.to(@vehicle.pos()).rotation(pos(0,-1))
        
        rct = rect w, h
        rct.sub pos w/2, h/2
        rct.scale @physics.zoom*1.02
        rct.rotate -gravAngle
            
        @ctx.save()
        
        @ctx.scale 1/@physics.zoom, 1/@physics.zoom
        @ctx.translate size.x/2, size.y/2
        @ctx.rotate deg2rad gravAngle
        
        if not streaks
            @stars.draw @ctx, rct, @physics.zoom, pos @vehicle.body.velocity
        
        @ctx.translate -@physics.center.x, -@physics.center.y

        for planet in @planets
            planet.draw @ctx
        
        @vehicle.draw @ctx
        
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
    
    onKeyDown: (event) => {mod, key, combo, char} = keyinfo.forEvent event
    onKeyUp:   (event) => {mod, key, combo, char} = keyinfo.forEvent event
                        
module.exports = Kugel
