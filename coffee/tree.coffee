###
000000000  00000000   00000000  00000000
   000     000   000  000       000     
   000     0000000    0000000   0000000 
   000     000   000  000       000     
   000     000   000  00000000  00000000
###

tools  = require './knix/tools'
def    = require './knix/def'
Quat   = require './quat'
Bot    = require './bot'
Mesh   = require './mesh'
rndrng = tools.rndrng

class Tree extends Bot

    constructor: (config={}) ->
        
        @isTree = true
        @numKerns = 0
        
        @onKern = config.onKern
        
        super def config,
            height: 100
        
        new Mesh
            type:     'spike'
            material: 'tree'
            color:    config.color
            radius:   4
            parent:   @
        
    setKern: (kern) =>
        
        @kern = kern
        @onKern()
        
module.exports = Tree
