
#  0000000  000   000  000  00000000 
# 000       000   000  000  000   000
# 0000000   000000000  000  00000000 
#      000  000   000  000  000      
# 0000000   000   000  000  000      

{ elem, first, pos, sw, sh, log, _ } = require 'kxk'

svg = require './svg'

class Ship

    constructor: (@kugel) ->

        @angle  = 0
        @thrust = 0
        
        @ship = svg.add 'ship', parent:@kugel.svg

        @ship.style
            'stroke': '#fff'
            'stroke-width': 4
        
        @body = @kugel.physics.addItem @ship, x:sw()/2, y:sh()/2
        
module.exports = Ship
