
# 000   000  000000000  000  000       0000000    
# 000   000     000     000  000      000         
# 000   000     000     000  000      0000000     
# 000   000     000     000  000           000    
#  0000000      000     000  0000000  0000000     

{ log } = require 'kxk'

module.exports = 

    fadeAngles: (f, a, b) ->
        
        if      a-b >  180 then a -= 360
        else if a-b < -180 then a += 360
        (1-f) * a + f * b