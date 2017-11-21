
#  0000000  00000000    0000000    0000000  00000000  
# 000       000   000  000   000  000       000       
# 0000000   00000000   000000000  000       0000000   
#      000  000        000   000  000       000       
# 0000000   000        000   000   0000000  00000000  

{ deg2rad, keyinfo, stopEvent, elem, post, prefs, sw, sh, pos, log, $, _ } = require 'kxk'

Physics = require './physics'
Stars   = require './stars'
Pad     = require './pad'
Ship    = require './ship'
SVG     = require 'svg.js'

class Space

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
        @pad.addListener 'stick',       @onStick

        @canvas = elem 'canvas', id: 'stars'
        @canvas.style.position = 'absolute'
        @canvas.style.background = "#005"
        @canvas.style.top = '0'
        @canvas.style.left = '0'
        @element.appendChild @canvas
        @ctx = @canvas.getContext '2d'
        
        @stars   = new Stars   @, @canvas
        @physics = new Physics @, @element
        @ship    = new Ship @
        
        @physics.addBody 'pentagon', x:300,  y:0
        @physics.addBody 'ball',     x:0,    y:-300
        @physics.addBody 'trio',     x:-300, y:0, scale:0.2
        s = 90
        @physics.addBody 'pipe_corner', x:+s, y:+s, static:true, angle:90
        @physics.addBody 'pipe_corner', x:-s, y:+s, static:true, angle:180
        @physics.addBody 'pipe_corner', x:-s, y:-s, static:true, angle:-90

    # 000000000  000   0000000  000   000  
    #    000     000  000       000  000   
    #    000     000  000       0000000    
    #    000     000  000       000  000   
    #    000     000   0000000  000   000  
    
    beforeTick: (delta) ->
        
        @pad.emitEvents()
        @ship.beforeTick delta
        
    afterTick: (delta) ->
        
        @ship.afterTick delta
        @physics.center = pos @ship.body.position

    # 0000000    00000000    0000000   000   000  
    # 000   000  000   000  000   000  000 0 000  
    # 000   000  0000000    000000000  000000000  
    # 000   000  000   000  000   000  000   000  
    # 0000000    000   000  000   000  00     00  
    
    draw: (size, scale, w, h) ->
        
        @ctx.fillStyle = '#002'
        @ctx.fillRect 0, 0, w, h
        
        @stars.draw @physics.zoom, @ship.body.velocity
        @ship.draw size, scale, w, h
        
    onButtonDown: (button) =>
        
        switch button 
            when 'pad'          then @physics.toggleDebug()
            when 'options'      then post.toMain 'reloadWin'
            when 'R2', 'cross'  then @ship.fire true
            when 'triangle'     then @ship.toggleLaser()
            when 'square', 'L2' then @ship.brake true
            when 'L1'           then @ship.turn 'left',  true
            when 'R1'           then @ship.turn 'right', true
            when 'up'           then @physics.zoomIn()
            when 'down'         then @physics.zoomOut()

    onButtonUp: (button) =>
        
        switch button 
            when 'R2', 'cross'  then @ship.fire  false
            when 'square', 'L2' then @ship.brake false
            when 'L1'           then @ship.turn 'left',  false
            when 'R1'           then @ship.turn 'right', false
        
    onStick: (event) =>
        
        switch event.stick
            when 'L' then @ship.steer pos event.x, event.y
            
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
                        
module.exports = Space
