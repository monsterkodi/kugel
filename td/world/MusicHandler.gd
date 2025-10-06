class_name MusicHandler
extends Node

var world : World
var ambientCount = 0
var ambientTimer : Timer
var ambient : AudioStreamPlayer

func _ready():
    
    world = get_node("/root/World")
    Post.subscribe(self)
    
    %Ambient1.finished.connect(ambientFinished)
    %Ambient2.finished.connect(ambientFinished)
    %Ambient3.finished.connect(ambientFinished)
    
    ambientTimer = Timer.new()
    add_child(ambientTimer)
    ambientTimer.timeout.connect(randomAmbient) 
    
func stop():
    
    ambientTimer.stop()
    for child in get_children():
        child.stop()
        
func mainMenu(): playMenuMusic()

func menuAppear(menu:Control):
    
    if menu.name == "CreditsMenu":
        stop()
        %MenuMusicCredits.play()
        
func menuVanish(menu:Control):
    
    if menu.name == "CreditsMenu":
        playMenuMusic()

func playMenuMusic():
    
    stop()
    %MenuMusic.play()
    
func levelStart():
    
    stop()
        
    ambientCount = 0
    match world.currentLevel.name:
        "Linea":     ambient = %Ambient1
        "Circulus":  ambient = %Ambient2
        "Quadratum": ambient = %Ambient3
    ambient.play()

func ambientFinished():

    ambientCount += 1
    if ambientCount < 4:
        ambient.play()  
    else:
        ambientCount = 0
        ambientTimer.start(120)        
        
func randomAmbient():
    
    match randi_range(1,3):
        1: ambient = %Ambient1
        2: ambient = %Ambient2
        3: ambient = %Ambient3
        
    ambient.play()
    
