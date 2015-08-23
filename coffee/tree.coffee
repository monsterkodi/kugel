###
000000000  00000000   00000000  00000000
   000     000   000  000       000     
   000     0000000    0000000   0000000 
   000     000   000  000       000     
   000     000   000  00000000  00000000
###

tools    = require './knix/tools'
Mesh     = require './mesh'
rndrng   = tools.rndrng

class Tree extends Mesh

    constructor: () ->
        
        super 
            type:     'spike'
            material: 'tree'
            radius:   4
            position: vec(0,100,0)
        
        scene.add @

module.exports = Tree
