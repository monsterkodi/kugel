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
Note     = require './knix/note'
sound    = require './sound'
play     = Note.play
rndint   = tools.rndint
rndrng   = tools.rndrng
clamp    = tools.clamp
deg2rad  = tools.deg2rad
vec      = Vect.new

class Tree extends Bot

    constructor: (config={}) ->
        
        @isTree         = true
        @numKerns       = 0
        @level          = -1
        @branchesSound  = config.branchesSound
        @color          = config.color
        @onKern         = config.onKern
        @levelBranchNum = config.branches
        @kerns          = []
        @kernIndex      = -1
        @leaves         = [[vec(),0,45]]
        
        super def config,
            height: 100
        
        new Mesh             
            type:     'spike'
            material: 'tree'
            color:    @color
            radius:   4
            parent:   @
            
        @branches = new Branches
            num:    2048
            color:  @color
            parent: @
                    
    nextBranches: () =>
        @level += 1
        log @level
        play sound[@branchesSound]
        if @level < @levelBranchNum.length
            numChildBranches = @levelBranchNum[@level] 
        else
            numChildBranches = 1+rndint 2
        
        newLeaves = []
        for [leaf,angle,bngle] in @leaves
            
            for i in [0..numChildBranches-1]
                
                newLeaf = vec(0,0,clamp(1,45,45-@level*3))
                
                newBngle = bngle
                if numChildBranches > 1
                    newBngle += 2
                    newLeaf.applyQuaternion Quat.axis Vect.X, newBngle
                newAngle = angle + @level*90+i*360/numChildBranches
                newLeaf.applyQuaternion Quat.axis Vect.Z, newAngle
                newLeaf.add leaf
                
                l = @level < 5 and [100,150,190,220,240][@level] or 200+@level*10
                newLeaf.setLength l
                newLeaves.push [newLeaf, newAngle, newBngle]
                @branches.addVecs [leaf, newLeaf]
                
        @leaves = newLeaves          
        @branches.update()
        
        # log @leaves.length
                                
    setKern: (kern) =>
        
        @kern = kern
        @kerns.push kern
        @kernIndex += 1
                
        if @kernIndex >= @branches.count
            @onKern()
            @nextBranches()
        
        kern.target = @branches.head @kernIndex
        @localToWorld kern.target
        @branches.mark @kernIndex
        
module.exports = Tree
