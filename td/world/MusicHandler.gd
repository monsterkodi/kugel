class_name MusicHandler
extends Node

var world : World
var ambientCount = 0
var ambientTimer : Timer
var ambient : AudioStreamPlayer
const menuMusicVolume = db_to_linear(-9)
const menuMusicFadeTime = 9

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
    pass
    #if menu.name == "CreditsMenu":
        #stop()
        #%MenuMusicCredits.play()
        
func menuVanish(menu:Control):
    pass
    #if menu.name == "CreditsMenu":
        #playMenuMusic()

func playMenuMusic():
    
    if not %MenuMusic.playing:
        stop(false)
        #%MenuMusic.volume_linear = menuMusicVolume
        %MenuMusic.play()
    
func levelStart():
    
    stop()
    get_tree().create_timer(menuMusicFadeTime + 4).timeout.connect(randomAmbient)
        
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
    tween.tween_method(menuMusicFade, menuMusicVolume, 0.0, menuMusicFadeTime)
    
func menuMusicFade(value):
    
    %MenuMusic.volume_linear = value
    if value == 0.0:
        %MenuMusic.stop()
        %MenuMusic.volume_linear = 1.0
        #%MenuMusic.volume_linear = Settings.settings.volumeMusic
    
