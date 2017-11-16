
# 000  000   000  000000000  00000000  00000000    0000000  00000000   0000000  000000000
# 000  0000  000     000     000       000   000  000       000       000          000   
# 000  000 0 000     000     0000000   0000000    0000000   0000000   000          000   
# 000  000  0000     000     000       000   000       000  000       000          000   
# 000  000   000     000     00000000  000   000  0000000   00000000   0000000     000   

{ pos, log, _ } = require 'kxk'

class Intersect

    @rayBody: (start, end, body) ->
        
        minLength = Number.MAX_SAFE_INTEGER
        minIndex  = -1
        
        for index in [0...body.vertices.length]
            next = if index >= body.vertices.length-1 then 0 else index+1
            if @lines start, end, body.vertices[index], body.vertices[next]
                p = pos(body.vertices[index]).mid pos body.vertices[next]
                d = start.to(p).length()
                if d < minLength
                    minLength = d
                    minIndex = index
                    
        if minIndex >= 0
            next = if minIndex >= body.vertices.length-1 then 0 else minIndex+1
            return @linePos start, end, pos(body.vertices[minIndex]), pos(body.vertices[next])
            
        end

    @lines: (p1, q1, p2, q2) ->
        
        orientation = (p,q,r) ->
            val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)
            if val == 0 then return 0 # colinear
            return val > 0 and 1 or 2 # cw or ccw
        
        o1 = orientation p1, q1, p2
        o2 = orientation p1, q1, q2
        o3 = orientation p2, q2, p1
        o4 = orientation p2, q2, q1
 
        o1 != o2 and o3 != o4
        
    @linePos: (p, p2, q, q2) ->
    
        intersection = p2
    
        r   = p2.minus p
        s   = q2.minus q
        rxs = r.cross s
    
        if Math.abs(rxs) > 0.00000000001
    
            v = q.minus p
            t = v.cross(s)/rxs
            u = v.cross(r)/rxs
        
            if (0 <= t <= 1) and (0 <= u <= 1)
                intersection = p.plus r.times(t)
    
        intersection
    
module.exports = Intersect
