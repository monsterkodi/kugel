
# 000   000  000   000   0000000   00000000  000      
# 000  000   000   000  000        000       000      
# 0000000    000   000  000  0000  0000000   000      
# 000  000   000   000  000   000  000       000      
# 000   000   0000000    0000000   00000000  0000000  

{ deg2rad, keyinfo, stopEvent, post, prefs, sw, sh, pos, log, $, _ } = require 'kxk'

Physics = require './physics'
Space   = require './space'
Pad     = require './pad'
Ship    = require './ship'
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
        @pad.addListener 'stick',       @onStick

        @space = new Space @, @element
                
        @svg = SVG(@element).size '100%', '100%'
        @svg.style 
            position:'absolute'
            top:  0
            left: 0
        @svg.id 'svg'
        
        @physics = new Physics @, @element
        
        @ship = new Ship @
        
        cx = sw()/2
        cy = sh()/2
        # @physics.addBody 'pentagon', x:sw()*2/3, y:sh()/2
        # @physics.addBody 'ball',     x:sw()/2,   y:sh()/3
        @physics.addBody 'trio', x:cx, y:cy, scale:0.2
        s = 90
        @physics.addBody 'pipe_corner', { x:cx+s, y:cy-s }, static:true
        @physics.addBody 'pipe_corner', { x:cx+s, y:cy+s }, static:true, angle:90
        @physics.addBody 'pipe_corner', { x:cx-s, y:cy+s }, static:true, angle:180
        @physics.addBody 'pipe_corner', { x:cx-s, y:cy-s }, static:true, angle:-90
        
        @space.init()
        
    beforeTick: (delta) ->
        
        @ship.beforeTick delta
        
    afterTick: (delta) ->
        
        @ship.afterTick delta
        
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

    setViewBox: (x,y,w,h) ->
        
        @svg.viewbox x, y, w, h
        @space.onViewbox @svg.viewbox()
    
    # 000   000  00000000  000   000  
    # 000  000   000        000 000   
    # 0000000    0000000     00000    
    # 000  000   000          000     
    # 000   000  00000000     000     
    
    focus: -> @element.focus()
    
    onKeyDown: (event) =>
        
        {mod, key, combo, char} = keyinfo.forEvent event
        # log mod, key, combo, char

    onKeyUp: (event) =>
        
        {mod, key, combo, char} = keyinfo.forEvent event
                        
module.exports = Kugel
