# 00000000    0000000   0000000      
# 000   000  000   000  000   000    
# 00000000   000000000  000   000    
# 000        000   000  000   000    
# 000        000   000  0000000      

{ log, _ } = require 'kxk'

{ profile } = require './utils'

events = require 'events'

class Pad extends events
    
    @buttons = ['cross', 'circle', 'square', 'triangle', 'L1', 'R1', 'L2', 'R2', 'share', 'options', 'L3', 'R3', 'up', 'down', 'left', 'right', 'menu', 'pad']
    @indices = leftX:0, leftY:1, rightX:2, rightY:3, cross:0, circle:1, square:2, triangle:3, L1:4, R1:5, L2:6, R2:7, share:8, options:9, L3:10, R3:11, up:12, down:13, left:14, right:15, menu:16, pad:17
    
    constructor: ->

        super
        
        @buttons = Pad.buttons.map (b) -> pressed:false, value:0
        @axes    = [0,0,0,0]
        
        if not window.navigator.getGamepads? 
            return new Error 'The gamepad web api is not available'
  
        window.addEventListener 'gamepadconnected',    @onConnected
        window.addEventListener 'gamepaddisconnected', @onDisconnected
        
        @startPolling()
  
    onConnected: (event) =>
        
        if @getPad()
            log 'got pad'
            @stopPolling()
            @snapState()

    onDisconnected: (event) =>
        
        if 0 == event.gamepad.index
            @startPolling()
        
    startPolling: ->
        
        if not @pollInterval
            @pollInterval = window.setInterval @poll, 500
            
    stopPolling: ->
        
        window.clearInterval @pollInterval
        delete @pollInterval

    poll: =>
        
        if not @getPad() then window.dispatchEvent new Event 'gamepadconnected'
        
    getPad: -> 
        
        if window.navigator.getGamepads()[0]
            @stopPolling()            
            return window.navigator.getGamepads()[0]
        null

    snapState: -> 
        
        if gp = @getPad()
            for i in [0..17]
                b = gp.buttons[i]
                @buttons[i].value   = @round b.value, 0
                @buttons[i].down    = b.pressed and not @buttons[i].pressed
                @buttons[i].up      = not b.pressed and @buttons[i].pressed
                @buttons[i].pressed = b.pressed
            @axes = gp.axes.map (v) => @round v
            
    round: (v, deadzone=0.05) -> 
        
        r = parseInt(v*100)/100
        if Math.abs(r) < deadzone then r = 0
        r
       
    button: (name) -> @buttons[Pad.indices[name]]
    axis:   (name) -> @axes[Pad.indices[name]]
        
    emitEvents: =>
        
        if gp = @getPad()
            
            # prof = profile 'emitEvents'
            
            for index,button of gp.buttons
                
                if button.pressed and not @buttons[index].pressed
                    @emit 'buttondown', Pad.buttons[index]
                else if not button.pressed and @buttons[index].pressed
                    @emit 'buttonup', Pad.buttons[index]
                   
                if parseInt(index) in [6, 7]
                    if @round(button.value, 0) != @buttons[index].value
                        @emit 'buttonvalue', button:Pad.buttons[index], value:@round(button.value, 0)

            if @round(gp.axes[0]) != @axes[0] or @round(gp.axes[1]) != @axes[1]
                @emit 'stick', stick:'L', x:@round(gp.axes[0]), y:@round(gp.axes[1])

            if @round(gp.axes[2]) != @axes[2] or @round(gp.axes[3]) != @axes[3]
                @emit 'stick', stick:'R', x:@round(gp.axes[2]), y:@round(gp.axes[3])

            @snapState()
            
            # prof.end()
            
module.exports = Pad
    