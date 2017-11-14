
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
        
        @physics = new Physics @element
        
        @pad = new Pad()       
        @pad.addListener 'buttondown',  @onButton
        @pad.addListener 'buttonvalue', (event) -> log event
        @pad.addListener 'stick',       (event) -> log event
        
        @svg = SVG(@element).size '100%', '100%'
        @svg.id 'svg'
        @svg.clear()
        
        @ship = new Ship @
        
    onButton: (button) =>
        
        switch button 
            when 'cross'    then @physics.showDebug()
            when 'triangle' then @physics.showDebug false
        
    onResize: => 

        post.emit 'resize', pos sw(), sh()
        @world.setBounds sw(), sh()
                
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
