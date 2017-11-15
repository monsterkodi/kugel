
#  0000000  000   000   0000000 
# 000       000   000  000      
# 0000000    000 000   000  0000
#      000     000     000   000
# 0000000       0       0000000 

{ first, elem, fs, log, _ } = require 'kxk'

class kSVG

    @svgFile: (name) -> "#{__dirname}/../svg/#{name}.svg"
                    
    @add: (name, opt) ->

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
                                log 'def child'
                                parent.doc().defs().add defsChild
                        else if child.type in ['svg', 'g']
                            for layerChild in child.children()
                                items.push layerChild
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

                    bbox = group.rbox()
                    for item in group.children()
                        item.transform x:-bbox.cx, y:-bbox.cy, relative: true
                    
                    return group
                else
                    log 'dafuk? empty?', svg?
        log 'dafuk? no content?', name
        null
        
module.exports = kSVG
