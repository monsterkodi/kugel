
# 000   000  000   000   0000000   00000000  000      
# 000  000   000   000  000        000       000      
# 0000000    000   000  000  0000  0000000   000      
# 000  000   000   000  000   000  000       000      
# 000   000   0000000    0000000   00000000  0000000  

{ deg2rad, keyinfo, stopEvent, elem, post, prefs, sw, sh, pos, log, $, _ } = require 'kxk'

Physics = require './physics'
Stars   = require './stars'
Pad     = require './pad'
Car     = require './car'
SVG     = require 'svg.js'

class Kugel

    constructor: (element) ->

        prefs.init()
        
        @element =$ element
        
        @focus()
        
        @element.addEventListener 'keydown', @onKeyDown
        @element.addEventListener 'keyup',   @onKeyUp
                
        window.onresize = @onResize
        
        @pad = new Pad()       
        @pad.addListener 'buttondown',  @onButtonDown
        @pad.addListener 'buttonup',    @onButtonUp

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
        
        for i in [0..20]
            surface = @physics.addBody 'surface',  x:-3000+i*550, y:300, scale: 10, static: true
            # surface.friction = 1
            surface.collisionFilter.category = 2
            surface.collisionFilter.mask     = 0xffff
            
        @physics.addBody 'pentagon', x:-200, y:-300, scale: 0.1
        @physics.addBody 'ball',     x:-100, y:-300
        @physics.addBody 'trio',     x:-300, y:-200,    scale: 0.2
        
        @physics.engine.world.gravity.y = 0.3

    # 000000000  000   0000000  000   000  
    #    000     000  000       000  000   
    #    000     000  000       0000000    
    #    000     000  000       000  000   
    #    000     000   0000000  000   000  
    
    beforeTick: (delta) ->
        
        @pad.emitEvents()
        @car.beforeTick delta
        
    afterTick: (delta) ->
        
        @car.afterTick delta
        @physics.center = pos @car.body.position
       
    # 0000000    00000000    0000000   000   000  
    # 000   000  000   000  000   000  000 0 000  
    # 000   000  0000000    000000000  000000000  
    # 000   000  000   000  000   000  000   000  
    # 0000000    000   000  000   000  00     00  
    
    draw: (size, scale, w, h) ->
        
        @ctx.fillStyle = '#002'
        @ctx.fillRect 0, 0, w, h
        
        @stars.draw @physics.zoom, @car.body.velocity
        @car.draw size, scale, w, h
        
    onButtonDown: (button) =>
        
        switch button 
            when 'pad'          then @physics.toggleDebug()
            when 'options'      then post.toMain 'reloadWin'
            when 'cross'        then @car.jump()
            when 'square', 'L2' then @car.brake true
            when 'L1'           then @car.turn 'left',  true
            when 'R1'           then @car.turn 'right', true
            when 'up'           then @physics.zoomIn()
            when 'down'         then @physics.zoomOut()

    onButtonUp: (button) =>
        
        switch button 
            when 'square', 'L2' then @car.brake false
            when 'L1'           then @car.turn 'left',  false
            when 'R1'           then @car.turn 'right', false
                    
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
