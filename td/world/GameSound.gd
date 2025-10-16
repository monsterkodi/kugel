class_name  GameSound
extends Node

var volume    = { 
    "collect":        0.1, 
    "baseHit":        0.4,
    "baseDied":       0.4,
    "shieldDown":     0.4,
    "sniper":         0.5,
    "sniperFlute":    0.5,
    "sell":           0.2,
    "countdown":      0.2,
    "enemySpawned":   1.0 }
    
var maxdb     = { "countdown": 0.2, "enemySpeed": 0.5 }
var maxdist   = { "enemySpawned": 100.0, "shieldHit": 120.0, "baseHit": 120.0, "enemyBounce": 30.0, "move": 15.0 }
var seqsPitch = {}
var seqsIndex = {}
var randPitch = { "turret": [1.0, 0.9, 0.8, 0.7, 0.6]}
var poly      = {   "collect": 8, 
                    "dash": 3, 
                    "dashAir": 3, 
                    "land": 3, 
                    "laserDamage": 4, 
                    "baseHit": 3, 
                    "shieldHit": 3, 
                    "countdown": 16, 
                    "build": 4, 
                    "sell": 4, 
                    "enemySpeed": 4, 
                    "drop": 2 }
var pool      = { "enemyBounce": 16, "enemyCollision": 16, "enemyHit": 16, "enemyDied": 16, "enemySpawned": 3, "sentinel": 24, "sniper": 6, "sniperFlute": 6, "turret": 8, "laser": 4 }
var loop      = [ "move", "fly", "drive" ]
var soundPool = {}
var poolQueue = {}

func _ready():
    
    Post.subscribe(self)
    
    for child in get_children():
        
        if not child is AudioStreamPlayer3D: continue
        
        var sound : AudioStreamPlayer3D = child
        #Log.log("sound", sound.name)
        sound.bus = &"Game" 
        sound.max_distance = 70.0
        #sound.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
        sound.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
        #sound.attenuation_model = AudioStreamPlayer3D.ATTENUATION_LOGARITHMIC
        
        if poly.has(sound.name):
            sound.max_polyphony = poly[sound.name]
        if volume.has(sound.name):
            sound.volume_linear = volume[sound.name]
            #Log.log(sound.name, sound.volume_db)
        if maxdb.has(sound.name):
            sound.max_db = linear_to_db(maxdb[sound.name])
        if maxdist.has(sound.name):
            sound.max_distance = maxdist[sound.name]
        if pool.has(sound.name):
            soundPool[sound.name] = Node3D.new()
            poolQueue[sound.name] = []
            add_child(soundPool[sound.name])
            for i in range(pool[sound.name]):
                soundPool[sound.name].add_child(sound.duplicate())

func distance(dict:Dictionary) -> float:
    
    return dict.pos.distance_to(%Camera.followCameraPosition())

func _process(delta: float):
    
    for key in poolQueue:
        if poolQueue[key].is_empty():
            if key == "laser":
                for child in soundPool[key].get_children():
                    child.stop()
            continue
        poolQueue[key].sort_custom(func(a, b): return distance(a) < distance(b))
        for item in poolQueue[key]:
            for i in soundPool[key].get_child_count():
                if not soundPool[key].get_child(i).playing:
                    var sound = soundPool[key].get_child(i)
                    sound.global_position = item.pos
                    match key:
                        "enemySpawned":
                            sound.pitch_scale = 1.0+item.factor*0.125
                        "enemyCollision", "enemyBounce":
                            var vol = 1.0
                            if volume.has(key): vol = volume[key]
                            sound.volume_linear = vol * item.volume
                            sound.pitch_scale = clampf(4.0 - item.factor, 1.0, 4.0)
                            #Log.log(key, item.factor, item.volume, vol * item.volume, sound.pitch_scale)
                        "enemyDied", "enemyHit", "sniper", "sniperFlute", "sentinel", "turret":
                            sound.pitch_scale = getRandPitch(key)
                            var vol = 1.0
                            if volume.has(key): vol = volume[key]
                            sound.volume_linear = vol * randf_range(0.2, 1.0)
                        "laser":
                            #Log.log("laser", item.pos, item.factor)
                            sound.pitch_scale = item.factor
                        
                    sound.play()
                    break
        poolQueue[key] = []

func getRandPitch(key):
    
    if randPitch.has(key):
        return randPitch[key][randi_range(0, randPitch[key].size()-1)]
        
    return [1.0, 1.25, 1.5, 1.75, 2.0][randi_range(0, 4)]
    
func getSeqsPitch(key):
    
    if seqsPitch.has(key) and seqsIndex.has(key):
        seqsIndex[key] += 1
        if seqsIndex[key] >= seqsPitch[key].size():
            seqsIndex[key] = 0
        return seqsPitch[key][seqsIndex[key]]
    return 1.0

func gameSound(source:Node3D, action:String, factor:float = 0.0, vol:float = 1.0):
    
    if pool.has(action):
        poolQueue[action].append({"pos":source.global_position, "factor":factor, "volume":vol})
        return
    
    var sound:AudioStreamPlayer3D = find_child(action)
    if sound: 
        
        if sound.playing and not poly.has(action): return
        
        match action:
            
            "collect":
                sound.pitch_scale = 1.0 + mini(Wallet.balance, 300)/100.0
            "land":
                sound.max_db = linear_to_db(clampf(factor/100.0, 0.0, 1.0))
            "hit":
                sound.max_db = linear_to_db(clampf(factor/100.0, 0.0, 1.0))
                sound.pitch_scale = 2.0 - clampf(factor/100.0, 0.0, 1.0)
            "shieldHit":
                sound.pitch_scale = 1.0 + factor*0.1
            "baseHit":
                sound.pitch_scale = 0.5 + factor*0.25
            "countdown":
                sound.pitch_scale = 1.0 + factor
                #Log.log("baseHit", factor, sound.pitch_scale)
            "laserDamage":
                #Log.log("laserDamage", factor, 1.0/factor, 0.15/factor, clampf(0.15/factor, 0.2, 2.0))
                sound.volume_linear = clampf(factor/2, 0.0, 1.0)
                sound.pitch_scale   = clampf(0.15/factor, 0.2, 2.0)
            "enemySpeed":
                sound.pitch_scale   = factor
                
        sound.global_position = source.global_position        
        sound.play()
        
    else: Log.log("can't find sound for action", action)

func gameLoop(source:Node3D, action:String, vol:float = 0.0, pitch:float = 1.0):
    
    var sound:AudioStreamPlayer3D = find_child(action)
    if vol and not sound.playing:
        sound.play()
    elif vol <= 0 and sound.playing:
        sound.stop()
        return
    sound.global_position = source.global_position  
    sound.volume_linear = vol
    sound.pitch_scale   = maxf(0.001, pitch)
    
func gamePaused():
    
    for action in loop:
        var sound:AudioStreamPlayer3D = find_child(action)
        sound.stop()
