###
 0000000    0000000   00     00  00000000
000        000   000  000   000  000     
000  0000  000000000  000000000  0000000 
000   000  000   000  000 0 000  000     
 0000000   000   000  000   000  00000000
###

Planet   = require './planet'
Player   = require './player'
Snake    = require './snake'
Boid     = require './boid'
Mesh     = require './mesh'
log      = require './knix/log'
    
class Game
    
    constructor: (truck,renderer) ->
        
        @truck = truck
        
        @player = new Player()
                                
        @snakes = []
        for i in [0..10]
            @snakes.push new Snake()

        @boids = []
        for i in [0..20]
            @boids.push new Boid()
        
        @planet = new Planet()   
        @cursor = new THREE.Vector2 0,0 
                        
    mouse: (pos) => @cursor = pos
        
    frame: (step) =>

        # f = step.dsecs * 2
        # @truck.setQuat @truck.camera.getWorldQuaternion().slerp(@player.ctra.getWorldQuaternion(),f)
        
        @player.setTargetCamera @cursor, @truck.camera
        @player.frame step 
            
        for snake in @snakes
            snake.frame step
            
        for boid in @boids
            boid.frame step
                                                    
module.exports = Game
