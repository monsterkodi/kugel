
#  0000000  000   000  000  00000000 
# 000       000   000  000  000   000
# 0000000   000000000  000  00000000 
#      000  000   000  000  000      
# 0000000   000   000  000  000      

{ elem, first, fs, sw, sh, log, _ } = require 'kxk'

class Ship

    constructor: (@kugel) ->

        @ship = @addSVG 'ship', parent:@kugel.svg
        
        @ship.style 
            'stroke': '#fff'
            'stroke-width': 4
        @ship.cx sw()/2
        @ship.cy sh()/2
        
        @kugel.physics.addItem ship

    svgFile: (name) -> "#{__dirname}/../svg/#{name}.svg"
        
    addSVG: (name, opt) ->

        svgStr = fs.readFileSync @svgFile(name), encoding: 'utf8'
        
        e = elem 'div'
        e.innerHTML = svgStr
                
        parent = opt.parent

        for elemChild in e.children
            
            if elemChild.tagName == 'svg'
    
                svg = SVG.adopt elemChild
                
                if svg? and svg.children().length
    
                    children = svg.children()
                    items = []
                                            
                    for child in children
                        if child.type == 'defs'
                            for defsChild in child.children()
                                parent.doc().defs().add defsChild
                        else if opt?.id and child.type == 'svg'
                            g = svg.group()
                            for layerChild in child.children()
                                layerChild.toParent g
                            items.push g
                        else
                            items.push child
                          
                    if items.length == 1 and first(items).type == 'g'
                        group = first items 
                    else
                        group = svg.group()
                        for item in items
                           group.add item
                        
                    group.id name
                    parent.add group
                    
                    return group
                else
                    log 'dafuk? empty?', svg?
        null
        
module.exports = Ship
