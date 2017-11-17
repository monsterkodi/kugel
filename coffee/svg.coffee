
#  0000000  000   000   0000000 
# 000       000   000  000      
# 0000000    000 000   000  0000
#      000     000     000   000
# 0000000       0       0000000 

{ first, elem, pos, fs, log, _ } = require 'kxk'

Matter = require 'matter-js'

class kSVG
    
    @vertices = {}

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

                    bbox = group.bbox()
                    for item in group.children()
                        item.transform x:-bbox.cx, y:-bbox.cy, relative: true
                        
                    return group
        null
      
    @cloneItem: (name, defs) ->
        
        for def in defs.children()
            if def.id() == name
                return def.clone()
        
        item = @add name, parent:defs
        item.id name
        return item.clone()
        
    @cloneBody: (name, defs) ->
        
        for def in defs.children()
            if def.id() == name
                item = def
                break
            
        if not item?
            template = @add name, parent:defs
            template.id name
            
            body = Matter.Bodies.fromVertices 0, 0, @verticesForItem first template.children()
            dx = (body.bounds.min.x + body.bounds.max.x)/2
            dy = (body.bounds.min.y + body.bounds.max.y)/2
            
            for child in template.children()
                child.transform x:dx, y:dy, relative: true
                
            @vertices[name] = @verticesForItem first template.children()
            
            item = template
    
        body = Matter.Bodies.fromVertices 0, 0, @vertices[name],
            render:
                fillStyle:   'none'
                strokeStyle: '#88f'
                lineWidth:   1
            frictionStatic:  0
            frictionAir:     0
            friction:        0
            density:         1
            restitution:     0.5
                                                                
        body.item = item.clone()
        body

    @verticesForItem: (item) ->

        subdivisions = 3
        points = item.array().valueOf()
        
        indexPoints = []
        for index,point of points
            indexPoints.push [index, point]

        positions = []
        
        addPos = (p) => positions.push @transform item, p
        
        for [index, point] in indexPoints
            switch point[0]
                when 'S', 'Q', 'C'
                    if index > 0
                        for subdiv in [1..subdivisions]
                            addPos @deCasteljauPos points, index, point, subdiv/(subdivisions+1)
            addPos @posForPoint point
            
        positions.pop() if item.type != 'polygon'
        positions

    @itemMatrix: (item) ->
        
        m = item.transform().matrix.clone()
        for ancestor in item.parents()
            m = ancestor.transform().matrix.multiply m            
        m
        
    @transform: (item, p) ->
        
        pos new SVG.Point(p).transform @itemMatrix item
        
    @posForPoint: (point) ->
                
        switch point[0]
            when 'C'      then pos point[5], point[6]
            when 'S', 'Q' then pos point[3], point[4]
            when 'M', 'L' then pos point[1], point[2]
            else               pos point[0], point[1]
    
    @posAt: (points, index, dot='point') ->

        point = points[(points.length + index) % points.length]

        switch dot
            when 'point' then @posForPoint point
            when 'ctrl1', 'ctrls', 'ctrlq' then pos point[1], point[2]
            when 'ctrl2'                   then pos point[3], point[4]
            else
                log "Points.posAt -- unhandled dot? #{dot}"
                pos point[1], point[2]
        
    @deCasteljauPos: (points, index, point, factor) ->
        
        thisp = @posAt points, index
        prevp = @posAt points, index-1
        
        switch point[0]
            when 'C'
                ctrl1 = @posAt points, index, 'ctrl1'
                ctrl2 = @posAt points, index, 'ctrl2'
            when 'Q'
                ctrl1 = @posAt points, index, 'ctrlq'
                ctrl2 = ctrl1
            when 'S'
                ctrl1 = @posAt points, index, 'ctrlr'
                ctrl2 = @posAt points, index, 'ctrls'

        p1 = prevp.interpolate ctrl1, factor
        p2 = ctrl1.interpolate ctrl2, factor
        p3 = ctrl2.interpolate thisp, factor
        
        p4 = p1.interpolate p2, factor
        p5 = p2.interpolate p3, factor
        p6 = p4.interpolate p5, factor
        
module.exports = kSVG
