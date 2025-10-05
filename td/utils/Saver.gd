extends Node

var savegame : SaveGame

func _ready(): 
    
    savegame = SaveGame.new()
    assert(savegame.data != null)
    Log.log("Saver.ready")

func save():

    var levelData 
    if savegame and savegame.data.has("Level"):
        levelData = savegame.data.Level
    savegame = SaveGame.new()
    Settings.save(savegame.data)
    get_tree().call_group("save", "on_save", savegame.data)
    if levelData:
        savegame.data.Level = levelData
    Log.log("save", savegame.data)
    ResourceSaver.save(savegame, "user://savegame.tres")

func clear():
    
    savegame = SaveGame.new()
    ResourceSaver.save(savegame, "user://savegame.tres")
    self.load()
    
func load():

    if ResourceLoader.exists("user://savegame.tres"):
        savegame = load("user://savegame.tres")
        if savegame:
            Log.log("load", savegame.data)
            Settings.load(savegame.data)
            get_tree().call_group("save", "on_load", savegame.data)
