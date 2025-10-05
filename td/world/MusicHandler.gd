class_name MusicHandler
extends Node

var world : World

func _ready():
    
    world = get_node("/root/World")
    Post.subscribe(self)
    
func stop():
    
    for child in get_children():
        child.stop()
        
func mainMenu():   playMenuMusic()
#func gamePaused(): playMenuMusic()

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
    #match world.currentLevel.name:
        #"Linea":     %SketchReverb.play()
        #"Circulus":  %SketchReverb.play()
        #"Quadratum": %SketchReverb.play()
