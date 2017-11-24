
# 00000000   00000000   0000000  000000000
# 000   000  000       000          000   
# 0000000    0000000   000          000   
# 000   000  000       000          000   
# 000   000  00000000   0000000     000   

{ pos, log, _ } = require 'kxk'

intersect = require './intersect'

class Rect

    constructor: (p1,p2,p3,p4) ->
        
        if not p2?
            @points = [pos(p1[0]),pos(p1[1]),pos(p1[2]),pos(p1[3])]
        else if not p3?
            if _.isNumber(p1) and _.isNumber(p2)
                @points = [pos(0,0), pos(p1,0), pos(p1,p2), pos(0,p2)]
            else 
                @points = [p1, pos(p1.y, p2.x), p2, pos(p1.x, p2.y)]
        else
            if _.isNumber(p1) and _.isNumber(p2)
                @points = [pos(p1,p2), pos(p1+p3,p2), pos(p1+p3,p2+p4), pos(p1,p2+p4)]
            else
                @points = [p1, p2, p3, p4]

    copy: -> new Rect @points
                
    center: -> @points[0].mid @points[2]
    
    minRadiusSquare: -> 
        c = @center()
        Math.min c.distSquare(@top()), c.distSquare(@right())
        
    maxRadiusSquare: -> @center().distSquare @topRight()
        
    intersectLine: (a, b) ->
        for i in [0...4]
            if bp = intersect.linePos a, b, @points[i], @points[(i+1)%4]
                return bp
        null
        
    contains: (p) -> null == @intersectLine @center(), p
        
    randomPos: -> 
        c = @center()
        h = c.to(@right()).times _.random -1, 1, true
        v = c.to(@bot()).times   _.random -1, 1, true
        c.plus(h).plus(v) 
        
    width:  -> @topLeft().to(@topRight()).length()
    height: -> @topLeft().to(@botLeft()).length()
        
    top:   -> @topLeft().mid @topRight()
    right: -> @topRight().mid @botRight()
    bot:   -> @botLeft().mid @botRight()
    left:  -> @topLeft().mid @botLeft()
        
    topLeft:  -> @points[0]
    topRight: -> @points[1]
    botRight: -> @points[2]
    botLeft:  -> @points[3]
    
    sub: (v) ->
        for p in @points
            p.sub v
        @
            
    add: (v) ->
        for p in @points
            p.add v
        @
        
    scale: (v) ->
        for p in @points
            p.scale v
        @
            
    rotate: (v) ->
        for p in @points
            p.rotate v
        @
            
module.exports = (p1,p2,p3,p4) -> new Rect p1,p2,p3,p4
