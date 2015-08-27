###
000000000  00000000   00000000  00000000
   000     000   000  000       000     
   000     0000000    0000000   0000000 
   000     000   000  000       000     
   000     000   000  00000000  00000000
###

tools    = require './knix/tools'
dbg      = require './knix/log'
log      = require './knix/log'
def      = require './knix/def'
Branches = require './branches'
Quat     = require './quat'
Vect     = require './vect'
Line     = require './line'
Bot      = require './bot'
Mesh     = require './mesh'
rndint   = tools.rndint
rndrng   = tools.rndrng
clamp    = tools.clamp
deg2rad  = tools.deg2rad
vec      = Vect.new

class Tree extends Bot

    constructor: (config={}) ->
        
        @isTree = true
        @numKerns = 0
        @levelBranchNum = config.branches
        @levelBranches = []
        @level = -1
        @bobls = []
        @color = config.color
        @onKern = config.onKern
        
        super def config,
            height: 100
        
        @meshDef =            
            detail:   config.detail
            type:     config.type or 'spike'
            material: 'tree'
            color:    @color
            radius:   4
        
        new Mesh def @meshDef,
            parent:   @
            
        @branches = new Branches
            num:    2048
            color:  @color
            parent: @
            
        @kerns = []
        @kernIndex = 0
        @leaves = [vec()]
        @nextBranches()

    nextBranches: () =>
        @level += 1
        
        if @level < @levelBranchNum.length
            numChildBranches = @levelBranchNum[@level] 
        else
            numChildBranches = 1+rndint 2
        
        newLeaves = []
        for leaf in @leaves
            
            for i in [0..numChildBranches-1]
                
                newLeaf = vec(0,0,clamp(1,25,25-@level+2*0.1))
                newLeaf.applyQuaternion Quat.axis Vect.X, 45
                newLeaf.applyQuaternion Quat.axis Vect.Z, @level*90+i*360/numChildBranches
                newLeaf.add leaf
                newLeaves.push newLeaf
                @branches.addVecs [leaf, newLeaf]
                
        @branches.update()
        @leaves = newLeaves  
        log @leaves.length
                                
    setKern: (kern) =>
        
        @kern = kern
        @kerns.push kern
        @kernIndex += 1
                
        # log 'set kern', @level, @kerns.length, @kernIndex, @branches.count
                
        if @kernIndex >= @branches.count
            # log 'next'
            @onKern()
            @nextBranches()
        
        kern.target = @branches.head @kernIndex
        @localToWorld kern.target
        
module.exports = Tree
