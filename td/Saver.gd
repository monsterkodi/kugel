class_name Saver
extends Node

func save():

    var savegame = SaveGame.new()
    get_tree().call_group("save", "on_save", savegame.data)
    ResourceSaver.save(savegame, "user://savegame.tres")
    
func load():
    #return
    var savegame:SaveGame = load("user://savegame.tres")
    if savegame:
        get_tree().call_group("save", "on_load", savegame.data)
