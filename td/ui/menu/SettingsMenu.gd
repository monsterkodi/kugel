class_name SettingsMenu 
extends Menu

func _ready():
    
    backFrom = "top"
    Post.subscribe(self)
    super._ready()

func _on_visibility_changed():
    
    if is_visible_in_tree() and %Brightness.is_inside_tree():
        %Brightness.value = %Camera.get_node("Light").light_energy
        %Timescale.value  = Engine.time_scale
        %EnemySpeed.value = Info.enemySpeed
        %Volume.value     = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))
        %Clock.value      = HUD.showClock
             
        onBrightness(%Brightness.value)
        onTimescale(%Timescale.value)       
        onEnemySpeed(%EnemySpeed.value)
        onVolume(%Volume.value)
        
func appeared():
    
    %EnemySpeed.grab_focus()
    super.appeared()

func onButtonHover(button: Node): 
    
    button.grab_focus()

func onBrightness(value):
    
    %Camera.get_node("Light").light_energy = value
    
    %BrightnessValue.text = Utils.trimFloat(%Brightness.value, 1)

func onTimescale(value):
    
    Engine.time_scale = value
    if Engine.time_scale > 1:
        Engine.physics_ticks_per_second = 120
    else:
        Engine.physics_ticks_per_second = 60
        
    Log.log("ticks per second", Engine.physics_ticks_per_second, "timescale", Engine.time_scale)

    %TimescaleValue.text = Utils.trimFloat(%Timescale.value, 2)
    
func onEnemySpeed(value):
    
    Info.setEnemySpeed(value)

func enemySpeed(value):
        
    %EnemySpeedValue.text = Utils.trimFloat(%EnemySpeed.value, 1)

func onVolume(value):
    
    Post.statChanged.emit("volume", value)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
    
    %VolumeValue.text = str(int(%Volume.value))
    
func onClock(value):
    
    HUD.showClock = %Clock.value    
    
func on_save(data:Dictionary):

    data.Settings = {}
    data.Settings.timeScale  = Engine.time_scale
    data.Settings.enemySpeed = Info.enemySpeed
    data.Settings.brightness = %Camera.get_node("Light").light_energy
    data.Settings.volume     = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))
    data.Settings.clock      = HUD.showClock
    
func on_load(data:Dictionary):
    
    if not data.has("Settings"): return
    
    if data.Settings.has("timeScale"):  onTimescale(data.Settings.timeScale)
    if data.Settings.has("enemySpeed"): onEnemySpeed(data.Settings.enemySpeed)
    if data.Settings.has("brightness"): onBrightness(data.Settings.brightness)
    if data.Settings.has("volume"):     onVolume(data.Settings.volume)
    if data.Settings.has("clock"):      onClock(data.Settings.clock)
