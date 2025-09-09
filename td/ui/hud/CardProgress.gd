class_name CardProgress
extends PanelContainer

const CIRCLE = preload("uid://c2q8strea6bfu")
var player

func _ready():
    
    player = get_node("/root/World/Player")
    assert(player)
    Post.subscribe(self)
    
func levelStart(): update()

func enemySpawned(spawner:Spawner): update()
    
func applyCards(): update()

func update():
    
    var numCards = Info.nextCardAtLevel(player.cardLevel)
    
    if numCards != %Dots.get_child_count(): initDots(numCards)
    
    for i in range(numCards):
        if i > numCards-player.nextCardIn: %Dots.get_child(i).color = Color("343434ff")
        else:                               %Dots.get_child(i).color = Color("ff0000ff")

    Log.log("progress", numCards-player.nextCardIn, player.nextCardIn, numCards)

func initDots(num):
    
    Utils.freeChildren(%Dots)
    var diameter = minf(1500.0/num, 12.0)
    for i in range(num):
        var dot = CIRCLE.instantiate()
        dot.diameter = diameter
        %Dots.add_child(dot)
    
