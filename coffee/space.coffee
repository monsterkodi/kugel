
#  0000000  00000000    0000000    0000000  00000000
# 000       000   000  000   000  000       000     
# 0000000   00000000   000000000  000       0000000 
#      000  000        000   000  000       000     
# 0000000   000        000   000   0000000  00000000

{ last, sw, sh, pos, log, _ } = require 'kxk'

svg = require './svg'

class Space

    constructor: (@kugel, @element) ->

        @svg = SVG(@element).size '100%', '100%'
        @svg.style 
            position:'absolute'
            top:  0
            left: 0
        @svg.id 'space'
        
        @stars = []
        for i in [0...5]
            @stars.push @svg.group()
            
        for i in [0...4]
            stars = @stars[i]
            stars.style fill: ['#00a', '#11a', '#44d', '#88f'][i]
            for s in [0...100-i*20]
                size = i+2
                c = stars.rect size, size
                p = pos(0,1).rotate _.random 0,360,true
                p.scale 2 * sw() * (Math.pow(_.random(0, 1, true), 2)-0.5)
                c.center sw()/2+p.x, sh()/2+p.y
        
    onViewbox: (vbox) ->
        
        z = 0.1
        for stars in @stars
            stars.translate -vbox.x*z, -vbox.y*z
            z += 0.1
        
    init: ->
        
        # @addItem 'planet', x:sw()/2, y:sh()/2
        # @addItem 'moon',   x:sw()/2, y:sh()*3/4
        
    addItem: (name, opt) ->
        
        item = svg.cloneItem name, @kugel.svg.defs()
        item.translate opt.x, opt.y if opt.x? and opt.y?
        item.node.style.opacity = opt.opacity if opt.opacity?
        last(@stars).add item
        item
        
module.exports = Space
