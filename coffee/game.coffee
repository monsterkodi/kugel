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
                                
        @snakes = []
        for i in [0..10]
            @snakes.push new Snake()

        @boids = []
        for i in [0..8]
            @boids.push new Boid level:0
        for i in [0..8]
            @boids.push new Boid level:1
        for i in [0..8]
            @boids.push new Boid level:2
        
        @planet = new Planet()   
        @cursor = new THREE.Vector2 0,0 

        if true
            
            new Mesh
                type:     'spike'
                radius:   5
                detail:   1
                wireframe: true
                color:    0x0000ff
                position: vec(0,0,-100)

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
            
            if boid.position.distanceTo(@player.ball.localToWorld(vec())) < boid.radius
                @player.attachTo boid
        
        @player.setTargetCamera @cursor, @truck.camera
        @player.frame step 
        
                                                    
module.exports = Game
