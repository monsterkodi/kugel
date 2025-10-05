class_name  GameSound
extends Node

var seqsPitch = { "collect": [1.0, 1.125, 1.25, 1.375, 1.5 ] }
var seqsIndex = { "collect": 0 }
var randPitch = { }
var poly      = { "collect": 8, "dash": 3, "dashAir": 3, "land": 3 }
var volume    = { "dash": 0.2, "dashAir": 0.05, "collect": 0.05, "enemyHit": 0.1, "sniper": 0.2, "turret": 0.2, "enemySpawned": 0.3 }
var maxdb     = { "dash": 0.2, "dashAir": 0.1 }
var maxdist   = { "enemySpawned": 60.0 }
var pool      = { "enemyHit": 32, "enemyDied": 32, "enemySpawned": 8, "sentinel": 8, "sniper": 8, "turret": 8 }
var soundPool = {}
var poolQueue = {}

func _ready():
    
    Post.subscribe(self)
    
    for child in get_children():
        
        if not child is AudioStreamPlayer3D: continue
        
        var sound : AudioStreamPlayer3D = child
        #Log.log("sound", sound.name)
        sound.bus = &"Game" 
        sound.max_distance = 50.0
        #sound.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
        sound.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
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
        if poolQueue[key].is_empty(): continue
        poolQueue[key].sort_custom(func(a, b): return distance(a) < distance(b))
        for item in poolQueue[key]:
            for i in soundPool[key].get_child_count():
                if not soundPool[key].get_child(i).playing:
                    var sound = soundPool[key].get_child(i)
                    sound.global_position = item.pos
                    match key:
                        "enemySpawned":
                            sound.pitch_scale = 1.0+item.factor*0.125
                        "enemyDied", "enemyHit", "sniper", "sentinel", "turret":
                            sound.pitch_scale = getRandPitch(key)
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

func gameSound(source:Node3D, action:String, factor:float = 0.0):
    
    if pool.has(action):
        poolQueue[action].append({"pos":source.global_position, "factor":factor})
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
                
        sound.global_position = source.global_position        
        sound.play()
        
    else: Log.log("can't find sound for action", action)
