extends Node

static var Player = 1 << ( 1 - 1)
static var Enemy  = 1 << ( 2 - 1)
static var Static = 1 << ( 3 - 1)
static var Floor  = 1 << (32 - 1)

static func names(mask:int):
    
    var s := ""
    
    if mask & Player: s += "Player "
    if mask & Enemy:  s += "Enemy "
    if mask & Static: s += "Static "
    if mask & Floor:  s += "Floor "
    
    return s
