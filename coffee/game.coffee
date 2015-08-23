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
        log @level   
            
        if @level < 10
            @boids.push new Boid level:0
            @kerns.push new Kern bot: @boids[@boids.length-1]
        else
            if @level % 10 == 0
                @snakes.push new Snake()        
            if @level % 100 == 0
                @boids.push new Boid level:2
                @kerns.push new Kern bot: @boids[@boids.length-1]
            else if @level % 10 == 0
                @boids.push new Boid level:1
                @kerns.push new Kern bot: @boids[@boids.length-1]
                        
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
            
            if boid.position.distanceTo(@player.ball.localToWorld(vec())) < (boid.radius + 3)
                @player.attachTo boid
        
        @player.setTargetCamera @cursor, @truck.camera
        @player.frame step 
        
        for kern in @kerns
            kern.frame step
                                                    
module.exports = Game
