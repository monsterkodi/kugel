
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
        @pad.addListener 'buttondown',  @onButton
        @pad.addListener 'buttonvalue', @onValue
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
        
        pentagon = svg.add 'pentagon', parent:@svg
        @body = @physics.addItem pentagon, x:sw()*2/3, y:sh()/2

        ball = svg.add 'ball', parent:@svg
        @body = @physics.addItem ball, x:sw()/2, y:sh()/3
        
        trio = svg.add 'trio', parent:@svg
        @body = @physics.addItem trio, x:sw()/2, y:sh()*2/3

    onTick: (event) ->
        
        body = @ship.body
        dir = pos(0,-1).rotate body.angle*180.0/Math.PI
        body.applyForce dir.times @ship.thrust * 200
        body.addAngle @ship.angle/10
        
    onButton: (button) =>
        
        switch button 
            when 'cross'    then @physics.showDebug true
            when 'triangle' then @physics.showDebug false
            when 'circle'   then post.toMain 'reloadWin'

    onValue: (event) =>
        
        switch event.button
            when 'R2' 
                @ship.thrust = event.value
        
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
