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
    
func stop(fadeMenuMusic=true):
    
    ambientTimer.stop()
    for child in get_children():
        if child is AudioStreamPlayer and child.playing:
            if child == %MenuMusic:
                if fadeMenuMusic:
                    fadeOutMenuMusic()
            else:
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
    
    stop(false)
    %MenuMusic.play()
    
func levelStart():
    
    randomAmbient()    
        
func randomAmbient():
    
    stop()
    ambientCount = 0
    match randi_range(1,3):
        1: ambient = %Ambient1
        2: ambient = %Ambient2
        3: ambient = %Ambient3
        
    ambient.play()
    
func ambientFinished():

    ambientCount += 1
    if ambientCount < 4:
        ambient.play()  
    else:
        ambientCount = 0
        ambientTimer.start(120)        

func fadeOutMenuMusic():
    
    var tween = create_tween()
    tween.tween_method(menuMusicFade, 1.0, 0.0, 3.0)
    
func menuMusicFade(value):
    
    %MenuMusic.volume_linear = value * Settings.settings.volumeMusic
    if value == 0.0:
        %MenuMusic.stop()
        %MenuMusic.volume_linear = Settings.settings.volumeMusic
    
