
# 000   000  000   000   0000000   00000000  000      
# 000  000   000   000  000        000       000      
# 0000000    000   000  000  0000  0000000   000      
# 000  000   000   000  000   000  000       000      
# 000   000   0000000    0000000   00000000  0000000  

{ keyinfo, stopEvent, post, prefs, sw, sh, pos, log, $, _ } = require 'kxk'

Physics = require './physics'
Pad     = require './pad'
Ship    = require './ship'
SVG     = require 'svg.js'
svg     = require './svg'

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
        # @pad.addListener 'buttonvalue', @onValue
        @pad.addListener 'stick',       @onStick
        
        @svg = SVG(@element).size '100%', '100%'
        @svg.style 
            position:'absolute'
            top:  0
            left: 0
        @svg.id 'svg'
        @svg.clear()
        
        @physics = new Physics @, @element
        
        @ship = new Ship @
        
        addBody = (name, x, y) =>
            item = svg.add name, parent:@svg
            body = @physics.addItem item, x:x, y:y

            body.collisionFilter.group    = 3
            body.collisionFilter.category = 4
            body.collisionFilter.mask     = 0xffffffffff
            
        addBody 'pentagon', sw()*2/3, sh()/2
        addBody 'ball', sw()/2, sh()/3
        addBody 'trio', sw()/2, sh()*2/3

    onTick: (tick) ->
        
        @tickDelta = tick.source.delta
        @ship.onTick @tickDelta
        
    onButtonDown: (button) =>
        
        switch button 
            when 'L1'      then @physics.showDebug true
            when 'R1'      then @physics.showDebug false
            when 'options' then post.toMain 'reloadWin'
            when 'R1', 'cross' then @ship.fire true

    onButtonUp: (button) =>  
        switch button 
            when 'R1', 'cross' then @ship.fire false
        
    # onValue: (event) =>
#         
        # switch event.button
            # when 'R2' 
                # @ship.thrust = event.value
        
    onStick: (event) =>
        
        switch event.stick
            when 'L'
                @ship.angle = event.x
            when 'R'
                @ship.thrust = event.y < 0 and -event.y or -event.y/2
            
    onResize: => 

        post.emit 'resize', pos sw(), sh()
        @physics.setBounds sw(), sh()
                
    # 000   000  00000000  000   000  
    # 000  000   000        000 000   
    # 0000000    0000000     00000    
    # 000  000   000          000     
    # 000   000  00000000     000     
    
    focus: -> @element.focus()
    
    onKeyDown: (event) =>
        
        {mod, key, combo, char} = keyinfo.forEvent event
        log mod, key, combo, char

    onKeyUp: (event) =>
        
        {mod, key, combo, char} = keyinfo.forEvent event
                        
module.exports = Kugel
