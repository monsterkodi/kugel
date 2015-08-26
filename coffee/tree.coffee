###
000000000  00000000   00000000  00000000
   000     000   000  000       000     
   000     0000000    0000000   0000000 
   000     000   000  000       000     
   000     000   000  00000000  00000000
###

tools   = require './knix/tools'
dbg     = require './knix/log'
log     = require './knix/log'
def     = require './knix/def'
Quat    = require './quat'
Vect    = require './vect'
Line    = require './line'
Bot     = require './bot'
Mesh    = require './mesh'
rndint  = tools.rndint
rndrng  = tools.rndrng
clamp   = tools.clamp
deg2rad = tools.deg2rad
vec     = Vect.new

class Tree extends Bot

    constructor: (config={}) ->
        
        @isTree = true
        @numKerns = 0
        @levelBranchNum = config.branches or [1,2,3,4,1,2,3,4,1,2,3,4]
        @levelBranches = []
        @kernLevel = 0
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
            
        @nextLevel()
        
    delBobls: () =>
        for bobl in @bobls
            bobl.del()
        @bobls = []
                
    nextLevel: () =>
        @level += 1
        @kernLevel = 0
        @levelBranches.push []
        @delBobls()        
        leaves = @level > 0 and @levelBranches[@level-1] or [@]
        for leaf in leaves
            
            if @level < @levelBranchNum.length
                numChildBranches = @levelBranchNum[@level] 
            else
                numChildBranches = 1+rndint 2
            
            for i in [0..numChildBranches-1]
                length = clamp 4, 40, numChildBranches * (40-@level)
                head = Vect.Z.clone().multiplyScalar length 
                branch = new Line
                    color:  @color
                    from:   vec()
                    to:     head.clone()
                    parent: leaf
                branch.center = head
                @levelBranches[@level].push branch
                if @level > 0
                    branch.position.copy leaf.center
                    branch.rotateOnAxis Vect.Z, deg2rad(i*360/numChildBranches)
                    branch.rotateOnAxis Vect.X, deg2rad 20
        
    setKern: (kern) =>
        
        @kern = kern
                
        if @bobls.length == @levelBranches[@kernLevel].length
            
            if @kernLevel == @level
                log 'inc level'
                @onKern()
                @nextLevel()
            else
                log 'inc kern'
                @delBobls()
                @kernLevel += 1
                
            branch = @levelBranches[@kernLevel][0]
            
        else
            
            branch = @levelBranches[@kernLevel][@bobls.length]

        log 'set kern', @level, @kernLevel, @bobls.length , @levelBranches.length, @levelBranches[@kernLevel].length
        @bobls.push new Mesh def @meshDef,
            parent:   branch
            position: branch.center

        
module.exports = Tree
