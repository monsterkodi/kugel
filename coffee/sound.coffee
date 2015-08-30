###
 0000000   0000000   000   000  000   000  0000000  
000       000   000  000   000  0000  000  000   000
0000000   000   000  000   000  000 0 000  000   000
     000  000   000  000   000  000  0000  000   000
0000000    0000000    0000000   000   000  0000000  
###

# piano1 piano2 piano3 piano4 piano5 
# string1 string2 flute 
# bell1 bell2 bell3 bell4 
# organ1 organ2 organ3 organ4 
# fm1 fm2 fm3
# kick1 kick2 kick3 kick4  
# tom1 tom2
# perc1  
# snare1
# weird1 
# hihat1 hihat2 hihat3

module.exports = 
    jump: 
        # instr: 'hihat1'
        instr: 'perc1'
        
    land: 
        # instr: 'tom1'
        instr: 'snare1'

    boid1:
        instr: 'kick1'

    boid2:
        instr: 'kick2'

    boid3:
        instr: 'kick3'

    nextLevel:
        duration: 1.0
        instr: 'organ2'
        name: 'C3'
        # instr: 'kick4'

    kernPlayer:
        instr: 'hihat1'
        
    kernTree:
        duration: 0.4        
        instr: 'flute'
        name: 'C6'    
        
    kernFromPlayer:
        duration: 0.8
        instr: 'organ2'
        name: 'C4'
        
    branchesBlue: # blue 
        instr: 'organ1'
        duration: 0.7
        name: 'C5'
    
    branchesGray: # gray
        instr: 'organ2'
        duration: 0.7
        name: 'C5'

    branchesGreen: # green
        instr: 'organ1'
        duration: 0.7
        name: 'C7'

    branchesRed: # red
        instr: 'organ2'
        duration: 0.7
        name: 'C7'
