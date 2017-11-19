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
    
    constructor: ->

        super
        
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
            @buttons = gp.buttons.map (b) => pressed:b.pressed, value:@round(b.value, 0)
            @axes    = gp.axes.map (v) => @round v
            
    round: (v, deadzone=0.05) -> 
        
        r = parseInt(v*100)/100
        if Math.abs(r) < deadzone then r = 0
        r
                
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
    