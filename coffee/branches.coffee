###
0000000    00000000    0000000   000   000   0000000  000   000  00000000   0000000
000   000  000   000  000   000  0000  000  000       000   000  000       000     
0000000    0000000    000000000  000 0 000  000       000000000  0000000   0000000 
000   000  000   000  000   000  000  0000  000       000   000  000            000
0000000    000   000  000   000  000   000   0000000  000   000  00000000  0000000 
###

log   = require './knix/log'
tools = require './knix/tools'
Vect  = require './vect'
clamp = tools.clamp
vec   = Vect.new

class Branches extends THREE.Line
    
    constructor: (config={}) ->

        material = new THREE.LineBasicMaterial
            vertexColors: THREE.VertexColors
            blending:     THREE.AdditiveBlending
            transparent:  true
            linewidth:    2
            
        @color = new THREE.Color config.color
        
        @num   = config.num
        @used  = 0
        @count = 0

        @pos  = new Float32Array @num * 6
        @col  = new Float32Array @num * 6
        
        @geometry = new THREE.BufferGeometry()
        @geometry.addAttribute 'position', new THREE.DynamicBufferAttribute @pos, 3
        @geometry.addAttribute 'color',    new THREE.DynamicBufferAttribute @col, 3
        super @geometry, material, THREE.LinePieces
        (config.parent or scene).add @

    del: () => @parent.remove @ 

    head: (i) => vec @pos[i*6+3],@pos[i*6+4],@pos[i*6+5]
    mark: (i) => 
        for j in [0..5]
            @col[i*6+j] = clamp(0,1, 4 * @col[i*6+j])
        @update()

    addVecs: (vecs) => 
        for v in vecs
            @pos[@used*3+0] = v.x
            @pos[@used*3+1] = v.y
            @pos[@used*3+2] = v.z

            @col[@used*3+0] = @color.r*0.25
            @col[@used*3+1] = @color.g*0.25
            @col[@used*3+2] = @color.b*0.25
            @used += 1
        @count = parseInt @used/2
            
    update: () =>
        @geometry.attributes.position.needsUpdate = true
        @geometry.attributes.color.needsUpdate = true

module.exports = Branches
