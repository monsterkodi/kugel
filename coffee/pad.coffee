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
        
        @padIndex = -1

        if not window.navigator.getGamepads then return new Error('The gamepad web api is not available')
  
        window.addEventListener 'gamepadconnected',    @onGamepadConnected
        window.addEventListener 'gamepaddisconnected', @onGamepadDisconnected
        
        @startPolling()
  
    startPolling: ->
        
        if not @pollInterval
            @pollInterval = window.setInterval @poll, 500
            
    stopPolling: ->
        
        window.clearInterval @pollInterval
        delete @pollInterval

    poll: =>
        if not @getGamepad() then window.dispatchEvent new Event 'gamepadconnected'
        
    clearIndex: ->
        
        window.clearInterval @emitInterval
        @padIndex = -1
            
    getGamepad: -> 
        if @padIndex >= 0 and window.navigator.getGamepads()[@padIndex]
            @stopPolling()
            return window.navigator.getGamepads()[@padIndex]
        for index in [0..3]
            if window.navigator.getGamepads()[index]
                @padIndex = index
                @stopPolling()
                return window.navigator.getGamepads()[index]
        @clearIndex()
        null

    onGamepadConnected: (event) =>
        
        if @padIndex < 0 or not @getGamepad()
            log 'connected', @padIndex, event.gamepad?.index
            return if not event.gamepad?.index?
            @stopPolling()
            @padIndex = event.gamepad.index
            gp = @getGamepad()
            @snapState()
            @emitInterval = window.setInterval @emitEvents, 16

    onGamepadDisconnected: (event) =>
        if @padIndex == event.gamepad.index
            log 'disconnected', @padIndex, event.gamepad.index
            @clearIndex()
            @startPolling()

    snapState: -> 
        
        if gp = @getGamepad()
            @lastState = 
                buttons: gp.buttons.map (b) -> pressed:b.pressed
                axes: _.clone(gp.axes)
        
    emitEvents: =>
        
        if gp = @getGamepad()
            for index,button of gp.buttons
                if button.pressed and not @lastState.buttons[index].pressed
                    @emit 'buttondown', Pad.buttons[index]
                else if not button.pressed and @lastState.buttons[index].pressed
                    @emit 'buttonup', Pad.buttons[index]
                    
            @snapState()
            
module.exports = Pad
    