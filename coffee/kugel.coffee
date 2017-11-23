
# 000   000  000   000   0000000   00000000  000      
# 000  000   000   000  000        000       000      
# 0000000    000   000  000  0000  0000000   000      
# 000  000   000   000  000   000  000       000      
# 000   000   0000000    0000000   00000000  0000000  

{ rad2deg, deg2rad, keyinfo, stopEvent, elem, post, prefs, sw, sh, pos, log, $, _ } = require 'kxk'

Physics = require './physics'
Stars   = require './stars'
Pad     = require './pad'
Car     = require './car'
SVG     = require 'svg.js'
Matter  = require 'matter-js'
rect    = require './rect'

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
        
        @grav    = pos 0, 2200
        
        for i in [0..20]
            angle = i * 18
            p = pos(0,1900).rotate angle
            surface = @physics.addBody 'surface',  x:@grav.x+p.x, y:@grav.y+p.y, scale: 10, static: true
            Matter.Body.setAngle surface, deg2rad 180+angle
            surface.friction = 1
            surface.frictionStatic = 10
            surface.collisionFilter.category = 2
            surface.collisionFilter.mask     = 0xffff
            
        @physics.addBody 'pentagon', x:-200, y:-300, scale: 0.1,  frictionStatic: 2, friction: 0.1, density: 0.1
        @physics.addBody 'ball',     x:-100, y:-300,              frictionStatic: 2, friction: 0.1, density: 0.01
        @physics.addBody 'trio',     x:-300, y:-200, scale: 0.35, frictionStatic: 2, friction: 0.1, density: 0.01
        
    # 000000000  000   0000000  000   000  
    #    000     000  000       000  000   
    #    000     000  000       0000000    
    #    000     000  000       000  000   
    #    000     000   0000000  000   000  
    
    beforeUpdate: ->
        
        for body in Matter.Composite.allBodies @physics.engine.world
            if not body.isStatic
                bodyToCenter = pos(body.position).to(@grav).normal().scale(0.05)
                body.force.x += 0.008 * body.mass * bodyToCenter.x
                body.force.y += 0.008 * body.mass * bodyToCenter.y
    
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

        @ctx.fillStyle = '#002'
        @ctx.fillRect 0, 0, w, h
        
        gravAngle = - @grav.to(@car.pos()).rotation(pos(0,-1))
        
        rct = rect w, h
        rct.sub pos w/2, h/2
        rct.scale @physics.zoom*0.99
        rct.rotate -gravAngle
            
        @ctx.save()
                      
        @ctx.scale 1/@physics.zoom, 1/@physics.zoom
        @ctx.translate size.x/2, size.y/2
        @ctx.rotate deg2rad gravAngle
        
        @stars.draw rct, pos @car.body.velocity
        
        @ctx.translate -@physics.center.x, -@physics.center.y
                
        @car.draw()
        
        for body in @physics.bodies

            if body.image

                @ctx.save()
                @ctx.globalAlpha = body.opacity ? 1
                @ctx.translate body.position.x, body.position.y
                @ctx.rotate body.angle
                if _.isNumber body.scale then @ctx.scale body.scale, body.scale
                @ctx.globalCompositeOperation = body.compOp if body.compOp?
                @ctx.drawImage body.image.image, -body.image.image.width/2 + body.image.offset.x, -body.image.image.height/2 + body.image.offset.y
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
