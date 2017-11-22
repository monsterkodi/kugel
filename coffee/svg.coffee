
#  0000000  000   000   0000000 
# 000       000   000  000      
# 0000000    000 000   000  0000
#      000     000     000   000
# 0000000       0       0000000 

{ first, elem, pos, fs, log, _ } = require 'kxk'

{ growBox } = require './utils'

Matter = require 'matter-js'

class kSVG
    
    @items = {}
    @fakes = null

    # 000  00     00   0000000    0000000   00000000  
    # 000  000   000  000   000  000        000       
    # 000  000000000  000000000  000  0000  0000000   
    # 000  000 0 000  000   000  000   000  000       
    # 000  000   000  000   000   0000000   00000000  
    
    @image: (name) ->
       
        if not @items[name]?
            
            item = @add name
            item.id name
            
            @items[name] = image: @svgImage item
            
        @items[name].image
    
    @svgImage: (root, opt) ->

        svg = @svg root, opt
        img = new Image()
        img.src = window.URL.createObjectURL new Blob [svg], type: 'image/svg+xml;charset=utf-8'
        img

    #  0000000  000   000   0000000   
    # 000       000   000  000        
    # 0000000    000 000   000  0000  
    #      000     000     000   000  
    # 0000000       0       0000000   

    @svgFile: (name) -> "#{__dirname}/../svg/#{name}.svg"
        
    @svg: (root, opt) ->

        bb = opt?.box ? root.bbox()
        svgStr = "<svg width=\"#{bb.width}\" height=\"#{bb.height}\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:svgjs=\"http://svgjs.com/svgjs\" "
        svgStr += "\nstyle=\"stroke-linecap: round; stroke-linejoin: round; stroke-miterlimit: 20;\""
        svgStr += "\nviewBox=\"#{bb.x} #{bb.y} #{bb.width} #{bb.height}\">"
        
        for item in root.children()                    
            svgStr += '\n'
            svgStr += item.svg()
            
        svgStr += '</svg>'
        svgStr
        
    #  0000000   0000000    0000000    
    # 000   000  000   000  000   000  
    # 000000000  000   000  000   000  
    # 000   000  000   000  000   000  
    # 000   000  0000000    0000000    
    
    @add: (name, opt) ->

        svgStr = fs.readFileSync @svgFile(name), encoding: 'utf8'
        
        e = elem 'div'
        e.innerHTML = svgStr

        @fakes ?= SVG document.body
        
        for elemChild in e.children
            
            if elemChild.tagName == 'svg'
    
                svg = SVG.adopt elemChild
                
                if svg? and svg.children().length
    
                    children = svg.children()
                    items = []
                                            
                    for child in children
                        if child.type == 'defs' then
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
                    
                    @fakes.add group

                    bbox = group.bbox()
                    for item in group.children()
                        item.transform x:-bbox.cx, y:-bbox.cy, relative: true
                    
                    return group
        null
              
    #  0000000  000       0000000   000   000  00000000  
    # 000       000      000   000  0000  000  000       
    # 000       000      000   000  000 0 000  0000000   
    # 000       000      000   000  000  0000  000       
    #  0000000  0000000   0000000   000   000  00000000  
    
    @cloneBody: (name, opt) ->

        opt ?= {}
        
        if not @items[name]?
            
            item = @add name
            item.id name
            
            scale = 1
            if _.isNumber opt.scale
                scale = opt.scale
                item.scale scale, scale
            
            body = Matter.Bodies.fromVertices 0, 0, @verticesForItem first item.children()
            dx = (body.bounds.min.x + body.bounds.max.x)/2
            dy = (body.bounds.min.y + body.bounds.max.y)/2
                
            @items[name] = 
                vertices: @verticesForItem first item.children()
                image:    @svgImage item
                offset:   pos dx/scale, dy/scale
            
        body = Matter.Bodies.fromVertices 0, 0, @items[name].vertices,
            render:
                fillStyle:   'none'
                strokeStyle: '#88f'
                lineWidth:   1
            frictionStatic:  opt.frictionStatic ? 0
            frictionAir:     opt.frictionAir ? 0
            friction:        opt.friction ? 0
            density:         opt.density ? 1
            restitution:     opt.restitution ? 0.5
                                                                
        body.image = @items[name]
        body

    # 000   000  00000000  00000000   000000000  000   0000000  00000000   0000000  
    # 000   000  000       000   000     000     000  000       000       000       
    #  000 000   0000000   0000000       000     000  000       0000000   0000000   
    #    000     000       000   000     000     000  000       000            000  
    #     0      00000000  000   000     000     000   0000000  00000000  0000000   
    
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

    # 000  000000000  00000000  00     00  
    # 000     000     000       000   000  
    # 000     000     0000000   000000000  
    # 000     000     000       000 0 000  
    # 000     000     00000000  000   000  
    
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
        
    #  0000000   0000000    0000000  000000000  00000000  000            000   0000000   000   000  
    # 000       000   000  000          000     000       000            000  000   000  000   000  
    # 000       000000000  0000000      000     0000000   000            000  000000000  000   000  
    # 000       000   000       000     000     000       000      000   000  000   000  000   000  
    #  0000000  000   000  0000000      000     00000000  0000000   0000000   000   000   0000000   
    
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
