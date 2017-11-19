
# 000   000  000000000  000  000       0000000    
# 000   000     000     000  000      000         
# 000   000     000     000  000      0000000     
# 000   000     000     000  000           000    
#  0000000      000     000  0000000  0000000     

{ log } = require 'kxk'

now = require 'performance-now'

module.exports = 
    
    profile: (name) -> 
        start: now()
        name:  name
        end:   -> log "#{name}: #{(now()-@start).toFixed(3)}"

    insideBox: (p, box) -> box.x <= p.x <= box.x+box.width and box.y <= p.y <= box.y+box.height
    
    growBox: (box, percent=10) ->

        w = box.width * percent / 100
        box.width = box.width + 2*w
        box.x -= w
        
        h = box.height * percent / 100
        box.height = box.height + 2*h
        box.y -= h
        
        if box.w?  then box.w  = box.width
        if box.h?  then box.h  = box.height
        if box.x2? then box.x2 = box.x + box.width
        if box.y2? then box.y2 = box.y + box.height
        if box.cx? then box.cx = box.x + box.w/2
        if box.cy? then box.cy = box.y + box.h/2
        
        box
    