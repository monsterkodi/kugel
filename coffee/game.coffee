###
 0000000    0000000   00     00  00000000
000        000   000  000   000  000     
000  0000  000000000  000000000  0000000 
000   000  000   000  000 0 000  000     
 0000000   000   000  000   000  00000000
###

Planet   = require './planet'
Player   = require './player'
Tree     = require './tree'
Kern     = require './kern'
Snake    = require './snake'
Vect     = require './vect'
Line     = require './line'
Boid     = require './boid'
Mesh     = require './mesh'
log      = require './knix/log'
vec      = Vect.new
    
class Game
    
    constructor: (truck,renderer) ->
        
        @truck = truck
        
        @player = new Player()
        @planet = new Planet()
        @tree   = new Tree()
        @cursor = new THREE.Vector2 0,0 
                
        @kerns = []
        @snakes = []
        @boids = []
        @level = -1
        @nextLevel()
        
        if false
            
            new Line
                color: 0xff0000
                from: vec()
                to: vec(200,0,0)

            new Line
                color: 0x006600
                from: vec()
                to: vec(0,200,0)

            new Line
                color: 0x0000ff
                from: vec()
                to: vec(0,0,200)
        
    nextLevel: () =>
        
        @level += 1 
        
        @player.incSnatch()
        
        @tree.numKerns = 0
        log "level: ", @level   

        if @level % 20 == 0 and @boids.length
            @snakes.push new Snake()        
            
        if @boids.length < 60
            if @level % 3 == 0 and @boids.length
                @boids.push new Boid level:2
            else if @level % 2 == 0 and @boids.length
                @boids.push new Boid level:1            
            else
                @boids.push new Boid level:0
                    
        @kerns.push new Kern()           
                    
        for i in [0..@kerns.length-1]
            @kerns[i].attachTo @boids[i]
                        
    mouse: (pos) => @cursor.copy pos
        
    frame: (step) =>

        if @truck.isPivoting
        else
            f = step.dsecs * 2
            @truck.setQuat @truck.camera.getWorldQuaternion().slerp(@player.getWorldQuaternion(),f)
                    
        for snake in @snakes
            snake.frame step
            
        for boid in @boids
            boid.frame step
            
            distance = boid.position.distanceTo(@player.center)
            if distance < (boid.radius + 3)
                @player.attachTo boid
                
            if distance < @player.snatchDistance # attach on same level
                if boid.kern?
                    boid.kern.attachTo @player
        
        @player.setTargetCamera @cursor, @truck.camera
        @player.frame step 
        
        if @player.center.distanceTo(@tree.position) < 6
            if @player.kern?
                for kern in @kerns
                    if kern.bot == @player
                        log "kern delivered"
                        kern.attachTo @tree
                        @tree.numKerns += 1
                        if @tree.numKerns == @kerns.length
                            @nextLevel()
                        # @kerns.splice @kerns.indexOf(kern), 1
                        # kern.remove()
                        # if @kerns.length == 0
                            # @nextLevel()
        
        for kern in @kerns
            kern.frame step
                                                    
module.exports = Game
