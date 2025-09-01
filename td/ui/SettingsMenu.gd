class_name SettingsMenu 
extends Control

func _on_visibility_changed():
    
    if is_visible_in_tree() and %Brightness.is_inside_tree():
        %Brightness.value = %Camera.get_node("Light").light_energy
        %Timescale.value  = Engine.time_scale
        %EnemySpeed.value = Info.enemySpeed
        %EnemySpeed.grab_focus()

func onButtonHover(button: Node): 
    button.grab_focus()

func onBrightness(value):
    
    %Camera.get_node("Light").light_energy = value

func onTimescale(value):
    
    Engine.time_scale = value
    if Engine.time_scale > 1:
        Engine.physics_ticks_per_second = 120
    else:
        Engine.physics_ticks_per_second = 60
    #Log.log(Engine.physics_ticks_per_second, Engine.time_scale)

func onEnemySpeed(value):
    
    Info.enemySpeed = value
    Post.statChanged.emit("enemySpeed", Info.enemySpeed)

func on_save(data:Dictionary):

    data.Settings = {}
    data.Settings.timeScale  = Engine.time_scale
    data.Settings.enemySpeed = Info.enemySpeed
    data.Settings.brightness = %Camera.get_node("Light").light_energy
    
func on_load(data:Dictionary):
    
    if not data.has("Settings"): return
    if data.Settings.has("timeScale"):
        onTimescale(data.Settings.timeScale)
    if data.Settings.has("enemySpeed"):
        onEnemySpeed(data.Settings.enemySpeed)
    if data.Settings.has("brightness"):
        onBrightness(data.Settings.brightness)
