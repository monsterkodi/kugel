# 00000000    0000000   0000000      
# 000   000  000   000  000   000    
# 00000000   000000000  000   000    
# 000        000   000  000   000    
# 000        000   000  0000000      

{ log, _ } = require 'kxk'

events = require 'events'

class Pad extends events
    
    @buttons = ['cross', 'circle', 'square', 'triangle', 'L1', 'R1', 'L2', 'R2', 'share', 'options', 'L3', 'R3', 'up', 'down', 'left', 'right', 'menu', 'touch']
    
    constructor: ->

        super
        
        @connected = false

        if not window.navigator.getGamepads? 
            return new Error 'The gamepad web api is not available'
  
        window.addEventListener 'gamepadconnected',    @onConnected
        window.addEventListener 'gamepaddisconnected', @onDisconnected
        
        @startPolling()
  
    startPolling: ->
        
        if not @pollInterval
            @pollInterval = window.setInterval @poll, 500
            
    stopPolling: ->
        
        window.clearInterval @pollInterval
        delete @pollInterval

    poll: =>
        
        if not @getPad() then window.dispatchEvent new Event 'gamepadconnected'
        
    clearIndex: ->
        
        window.clearInterval @emitInterval
        @connected = false
            
    getPad: -> 
        
        if window.navigator.getGamepads()[0]
            @stopPolling()
            return window.navigator.getGamepads()[0]
                                
        @clearIndex()
        null

    onConnected: (event) =>
        
        if not @connected or not @getPad()
            if gp = @getPad()
                @stopPolling()
                @snapState()
                @emitInterval = window.setInterval @emitEvents, 16

    onDisconnected: (event) =>
        
        if 0 == event.gamepad.index
            @clearIndex()
            @startPolling()

    snapState: -> 
        
        if gp = @getPad()
            @lastState = 
                buttons: gp.buttons.map (b) => pressed:b.pressed, value:@round(b.value, 0)
                axes:    gp.axes.map (v) => @round v
        
    round: (v, deadzone=0.05) -> 
        
        r = parseInt(v*100)/100
        if Math.abs(r) < deadzone then r = 0
        r
                
    emitEvents: =>
        
        if gp = @getPad()
            
            for index,button of gp.buttons
                
                if button.pressed and not @lastState.buttons[index].pressed
                    @emit 'buttondown', Pad.buttons[index]
                else if not button.pressed and @lastState.buttons[index].pressed
                    @emit 'buttonup', Pad.buttons[index]
                   
                if parseInt(index) in [6, 7]
                    if @round(button.value, 0) != @lastState.buttons[index].value
                        @emit 'buttonvalue', button:Pad.buttons[index], value:@round(button.value, 0)

            if @round(gp.axes[0]) != @lastState.axes[0] or @round(gp.axes[1]) != @lastState.axes[1]
                @emit 'stick', stick:'L', x:@round(gp.axes[0]), y:@round(gp.axes[1])

            if @round(gp.axes[2]) != @lastState.axes[2] or @round(gp.axes[3]) != @lastState.axes[3]
                @emit 'stick', stick:'R', x:@round(gp.axes[2]), y:@round(gp.axes[3])
                
            @snapState()
            
module.exports = Pad
    