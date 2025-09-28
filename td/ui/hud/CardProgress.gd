class_name CardProgress
extends PanelContainer

const CIRCLE = preload("uid://c2q8strea6bfu")
var player
var tween : Tween
var preNum : int

func _ready():
    
    player = get_node("/root/World/Player")
    assert(player)
    Post.subscribe(self)
    
func levelStart():   update()
func applyCards():   update()
func enemySpawned(): update()
    
func preChooseAnim():
    
    preNum = 0
    tween = create_tween()
    tween.tween_method(onPreChoose, 0, %Dots.get_child_count()-1, 2.0)
    tween.tween_callback(preChooseAnimDone)
    
func onPreChoose(value):
    
    for i in range(preNum, value+1):
        var dot : Circle = %Dots.get_child(i)
        dot.color = Color(1,1,0)
        if i > 0:
            %Dots.get_child(i-1).color = Color(0,0,0)
    preNum = value
    
func preChooseAnimDone():
    
    Post.chooseCard.emit()

func update():
    
    if tween and tween.is_running(): return
    
    var numCards = Info.nextCardAtLevel(player.cardLevel)
    
    if numCards != %Dots.get_child_count(): 
        initDots(numCards)
    
    for i in range(numCards):
        if i > numCards-player.nextCardIn: %Dots.get_child(i).color = Color("343434ff")
        else:                              %Dots.get_child(i).color = Color("ff0000ff")

    #Log.log("progress", numCards-player.nextCardIn, player.nextCardIn, numCards)

func initDots(num):
    
    Utils.freeChildren(%Dots)
    var diameter = minf(1500.0/num, 12.0)
    for i in range(num):
        var dot = CIRCLE.instantiate()
        dot.diameter = diameter
        %Dots.add_child(dot)
