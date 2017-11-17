
#  0000000  00000000    0000000    0000000  00000000
# 000       000   000  000   000  000       000     
# 0000000   00000000   000000000  000       0000000 
#      000  000        000   000  000       000     
# 0000000   000        000   000   0000000  00000000

{ log } = require 'kxk'

svg = require './svg'

class Space

    constructor: (@kugel, @element) ->
        log 'space!'
        @svg = SVG(@element).size '100%', '100%'
        @svg.style 
            position:'absolute'
            top:  0
            left: 0
        @svg.id 'space'
        
    addItem: (name, opt) ->
        
        item = svg.cloneItem name, @kugel.svg.defs()
        item.translate opt.x, opt.y if opt.x? and opt.y?
        item.style.opacity = opt.opacity if opt.opacity?
        @svg.add item
        item
        
module.exports = Space
