###
 0000000    0000000   00     00  00000000
000        000   000  000   000  000     
000  0000  000000000  000000000  0000000 
000   000  000   000  000 0 000  000     
 0000000   000   000  000   000  00000000
###

Mesh = require './mesh'
log  = require './knix/log'

class Game
    
    constructor: (truck) ->
        @truck = truck
        @tgt = new THREE.Vector2 0,0
        @player = new Mesh
            type:   'spike'
            radius: 10
            color:  0xffffff
            dist:   110
            azim:   0
        
    mouse: (pos) =>
        @tgt = pos
        # log pos, @player.azim, @player.alti
        # @player.setAzimAlti @player.azim + pos.x, @player.alti + pos.y
        
    frame: =>
        s = 1
        @player.setAzimAlti @player.azim + @tgt.x * s, @player.alti + @tgt.y * s
        f = 0.01
        @truck.setAzimAlti @truck.azim * (1.0-f) + f * @player.azim, @truck.alti * (1.0-f) - f * @player.alti

module.exports = Game
