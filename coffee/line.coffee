###
000      000  000   000  00000000
000      000  0000  000  000     
000      000  000 0 000  0000000 
000      000  000  0000  000     
0000000  000  000   000  00000000
###

class Line extends THREE.Line

    constructor: (config={}) ->

        material = new THREE.LineBasicMaterial
            color: config.color? and config.color or 0xffffff
        
        @geometry = new THREE.Geometry()
        
        if config.from? and config.to?
            @geometry.vertices.push config.from, config.to
        else if config.lines?
            @addVecs config.lines 

        super @geometry, material, THREE.LinePieces
        (config.parent or scene).add @

    del: () => @parent.remove @ 
    
    addVecs: (vecs) => @geometry.vertices.push.apply @geometry.vertices, vecs 

module.exports = Line
