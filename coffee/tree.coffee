###
000000000  00000000   00000000  00000000
   000     000   000  000       000     
   000     0000000    0000000   0000000 
   000     000   000  000       000     
   000     000   000  00000000  00000000
###

tools  = require './knix/tools'
Quat   = require './quat'
Bot    = require './bot'
Mesh   = require './mesh'
rndrng = tools.rndrng

class Tree extends Bot

    constructor: () ->
        
        @isTree = true
        
        super 
            height: 100
            quat:   Quat.axis Vect.X, -90
        
        new Mesh
            type:     'spike'
            material: 'tree'
            radius:   4
            parent: @
        
module.exports = Tree
