
#  0000000  00000000    0000000    0000000  00000000  
# 000       000   000  000   000  000       000       
# 0000000   00000000   000000000  000       0000000   
#      000  000        000   000  000       000       
# 0000000   000        000   000   0000000  00000000  

{ deg2rad, keyinfo, stopEvent, elem, post, prefs, sw, sh, pos, log, $, _ } = require 'kxk'

Physics = require './physics'
Stars   = require './stars'
Pad     = require './pad'
Ship    = require './ship'
SVG     = require 'svg.js'
rect    = require './rect'

class Space

    constructor: (element) ->

        prefs.init()
        
        @element =$ element
        
        @focus()
        
        @element.addEventListener 'keydown', @onKeyDown
        @element.addEventListener 'keyup',   @onKeyUp
                
        window.onresize = @onResize
        
        @pad = new Pad()       

        @canvas = elem 'canvas', id: 'stars'
        @canvas.style.position = 'absolute'
        @canvas.style.background = "#005"
        @canvas.style.top = '0'
        @canvas.style.left = '0'
        @element.appendChild @canvas
        @ctx = @canvas.getContext '2d'
        
        @stars   = new Stars   @, @canvas
        @physics = new Physics @, @element
        @ship    = new Ship @
        
        @physics.addBody 'pentagon', x:300,  y:0
        @physics.addBody 'ball',     x:0,    y:-300
        @physics.addBody 'trio',     x:-300, y:0, scale:0.2
        s = 90
        @physics.addBody 'pipe_corner', x:+s, y:+s, static:true, angle:90
        @physics.addBody 'pipe_corner', x:-s, y:+s, static:true, angle:180
        @physics.addBody 'pipe_corner', x:-s, y:-s, static:true, angle:-90
        
        @onResize()

    # 000000000  000   0000000  000   000  
    #    000     000  000       000  000   
    #    000     000  000       0000000    
    #    000     000  000       000  000   
    #    000     000   0000000  000   000  
    
    beforeTick: (delta) ->
        
        @pad.snapState()
        @ship.beforeTick delta
        
    afterTick: (delta) ->
        
        @ship.afterTick delta
        @physics.center = pos @ship.body.position

    # 0000000    00000000    0000000   000   000  
    # 000   000  000   000  000   000  000 0 000  
    # 000   000  0000000    000000000  000000000  
    # 000   000  000   000  000   000  000   000  
    # 0000000    000   000  000   000  00     00  
    
    draw: () ->
        
        w = sw()
        h = sh()
        
        b = @physics.render.bounds
        size  = pos b.max.x - b.min.x, b.max.y - b.min.y
        scale = pos w/size.x, h/size.y

        @ctx.fillStyle = '#002'
        @ctx.fillRect 0, 0, w, h
        
        rct = rect w, h
        rct.sub pos w/2, h/2
        rct.scale @physics.zoom*0.99
            
        @ctx.save()
                      
        @ctx.scale 1/@physics.zoom, 1/@physics.zoom
        @ctx.translate size.x/2, size.y/2
        
        @stars.draw rct, @physics.zoom, pos @ship.body.velocity
        
        @ctx.translate -@physics.center.x, -@physics.center.y
                
        @ship.draw()
        
        for body in @physics.bodies

            if body.image

                @ctx.save()
                @ctx.globalAlpha = body.opacity ? 1
                @ctx.translate body.position.x, body.position.y
                @ctx.rotate body.angle
                if _.isNumber body.scale then @ctx.scale body.scale, body.scale
                @ctx.globalCompositeOperation = body.compOp if body.compOp?
                @ctx.drawImage body.image.image, -body.image.image.width/2 + body.image.offset.x, -body.image.image.height/2 + body.image.offset.y
                @ctx.restore()
                
        @ctx.restore()
                                    
    onResize: => @physics.setViewSize sw(), sh()

    # 000   000  00000000  000   000  
    # 000  000   000        000 000   
    # 0000000    0000000     00000    
    # 000  000   000          000     
    # 000   000  00000000     000     
    
    focus: -> @element.focus()
    
    onKeyDown: (event) =>
        
        {mod, key, combo, char} = keyinfo.forEvent event

    onKeyUp: (event) =>
        
        {mod, key, combo, char} = keyinfo.forEvent event
                        
module.exports = Space
