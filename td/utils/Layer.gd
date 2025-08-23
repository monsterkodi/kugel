extends Node

const LayerPlayer  = 1 << ( 1 - 1)
const LayerEnemy   = 1 << ( 2 - 1)
const LayerStatic  = 1 << ( 3 - 1)
const LayerBullets = 1 << ( 4 - 1)
const LayerSpawner = 1 << (31 - 1)
const LayerFloor   = 1 << (32 - 1)

static func names(mask:int):
    
    var s := ""
    
    if mask & LayerPlayer:  s += "Player "
    if mask & LayerEnemy:   s += "Enemy "
    if mask & LayerStatic:  s += "Static "
    if mask & LayerBullets: s += "Bullets "
    if mask & LayerSpawner: s += "Spawner "
    if mask & LayerFloor:   s += "Floor "
    
    return s
