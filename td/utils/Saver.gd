extends Node

var savegame : SaveGame

func save():

    savegame = SaveGame.new()
    get_tree().call_group("save", "on_save", savegame.data)
    ResourceSaver.save(savegame, "user://savegame.tres")

func clear():
    
    savegame = SaveGame.new()
    ResourceSaver.save(savegame, "user://savegame.tres")
    self.load()
    
func load():

    if ResourceLoader.exists("user://savegame.tres"):
        savegame = load("user://savegame.tres")
        if savegame:
            get_tree().call_group("save", "on_load", savegame.data)
