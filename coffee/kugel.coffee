
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

class Kugel

    constructor: (element) ->

        prefs.init()
        
        @element =$ element
        
        @focus()
        
        @element.addEventListener 'keydown', @onKeyDown
        @element.addEventListener 'keyup',   @onKeyUp
                
        window.onresize = @onResize
        
        
        @pad = new Pad()       
        @pad.addListener 'buttondown',  @onButton
        @pad.addListener 'stick',       @onStick
        
        @svg = SVG(@element).size '100%', '100%'
        @svg.style 
            position:'absolute'
            top:  0
            left: 0
        @svg.id 'svg'
        @svg.clear()
        
        @physics = new Physics @element
        
        @ship = new Ship @
        
    onButton: (button) =>
        
        switch button 
            when 'cross'    then @physics.showDebug()
            when 'triangle' then @physics.showDebug false
            when 'circle'   then post.toMain 'reloadWin'

    onStick: (event) =>
        
        switch event.stick
            when 'L'
                @ship.thrust pos event.x, event.y
            
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
