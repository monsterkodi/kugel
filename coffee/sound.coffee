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
        instr: 'perc1'
        
    land: 
        instr: 'bell4'
        duration: 0.4
        notes: ['C5', 'D5', 'E5', 'F5', 'A5', 'B5']

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
        #instr: 'hihat1'
        duration: 0.3
        instr: 'flute'
        octave: '6'
        
    kernTree:
        duration: 0.6        
        octave:'5'    
        
    kernFromPlayer:
        duration: 0.8
        instr: 'organ2'
        octave: '4'
        
    branchesBlue: # blue 
        instr: 'bell1'
        duration: 0.7
        name: 'C5'
    
    branchesGray: # gray
        instr: 'bell2'
        duration: 0.7
        name: 'C5'

    branchesGreen: # green
        instr: 'bell3'
        duration: 0.7
        name: 'C5'

    branchesRed: # red
        instr: 'bell4'
        duration: 0.7
        name: 'C5'
