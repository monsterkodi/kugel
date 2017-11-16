
# 000   000  000   000   0000000   00000000  000      
# 000  000   000   000  000        000       000      
# 0000000    000   000  000  0000  0000000   000      
# 000  000   000   000  000   000  000       000      
# 000   000   0000000    0000000   00000000  0000000  

{ deg2rad, keyinfo, stopEvent, post, prefs, sw, sh, pos, log, $, _ } = require 'kxk'

Physics = require './physics'
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
        
        @svg = SVG(@element).size '100%', '100%'
        @svg.style 
            position:'absolute'
            top:  0
            left: 0
        @svg.id 'svg'
        # @svg.clear()
        
        @physics = new Physics @, @element
        
        @ship = new Ship @
        
        @physics.addBody 'pentagon', x:sw()*2/3, y:sh()/2
        @physics.addBody 'ball',     x:sw()/2,   y:sh()/3
        @physics.addBody 'trio',     x:sw()/2,   y:sh()*2/3
        
        @physics.addBody 'pipe_corner', { x:sw()/3, y:sh()/3 }, static:true
        @physics.addBody 'pipe_corner', { x:sw()/3, y:sh()/3 }, static:true, angle:180

    onTick: (tick) ->
        
        @onResize()
        
        @tickDelta = tick.source.delta
        @ship.onTick @tickDelta
        
    onButtonDown: (button) =>
        
        switch button 
            when 'pad'          then @physics.toggleDebug()
            when 'options'      then post.toMain 'reloadWin'
            when 'R2', 'cross'  then @ship.fire true
            when 'triangle'     then @ship.toggleLaser()
            when 'square', 'L2' then @ship.brake true
            when 'L1'           then @ship.turn 'left',  true
            when 'R1'           then @ship.turn 'right', true

    onButtonUp: (button) =>
        
        switch button 
            when 'R2', 'cross'  then @ship.fire  false
            when 'square', 'L2' then @ship.brake false
            when 'L1'           then @ship.turn 'left',  false
            when 'R1'           then @ship.turn 'right', false
        
    onStick: (event) =>
        
        switch event.stick
            when 'L' then @ship.steer pos event.x, event.y
            when 'R'
                @ship.thrust = event.y < 0 and -event.y or -event.y/2
            
    onResize: => 

        # post.emit 'resize', pos sw(), sh()
        offset = pos(@ship.body.position).minus pos sw()/2, sh()/2
        @svg.viewbox offset.x, offset.y, sw(), sh()
        @physics.setBounds offset.x, offset.y, sw(), sh()
                
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
