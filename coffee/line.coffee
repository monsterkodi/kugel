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

        geometry = new THREE.Geometry()
        geometry.vertices.push config.from, config.to

        super geometry, material
        scene.add @

    remove: () => scene.remove @ 

module.exports = Line
