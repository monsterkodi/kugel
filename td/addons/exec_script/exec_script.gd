@tool
extends EditorPlugin

var shortcut = Shortcut.new()
var shortcutName : String

func _input(event):
    
    if shortcut.matches_event(event) and event.is_pressed() and not event.is_echo():
        get_viewport().set_input_as_handled()
        execScript()
        
func inputEventKeyFromString(shortcut:String) -> InputEventKey:
    
    var event = InputEventKey.new()
    var keycode = OS.find_keycode_from_string(shortcut)
    event.keycode       = keycode & ~KEY_MODIFIER_MASK
    event.shift_pressed = keycode & KEY_MASK_SHIFT
    event.meta_pressed  = keycode & KEY_MASK_META
    event.ctrl_pressed  = keycode & KEY_MASK_CTRL
    event.alt_pressed   = keycode & KEY_MASK_ALT
    return event

func _enter_tree() -> void:
    
    var defaultShortcut = "Ctrl+Alt+C"
    if OS.get_name() == "macOS":
         defaultShortcut = "Option+Command+C"
    var currentShortcut = defaultShortcut
    if get_setting("shortcut"): currentShortcut = get_setting("shortcut")
        
    var event = inputEventKeyFromString(currentShortcut)
 
    currentShortcut = OS.get_keycode_string(event.get_keycode_with_modifiers())
    
    Log.log("Exec Script:", currentShortcut)
    
    shortcut.events = [event]
       
    add_setting("path",     "git",           TYPE_STRING, PROPERTY_HINT_FILE)
    add_setting("args",     "status",        TYPE_STRING)
    add_setting("shortcut", defaultShortcut, TYPE_STRING)
    
    var command_palette = EditorInterface.get_command_palette()
    command_palette.add_command(scriptCommand(), "exec script", execScript, currentShortcut)
    
    ProjectSettings.settings_changed.connect(on_settings_changed)

func scriptCommand(): 
    
    return get_setting("path") + " " + get_setting("args")

func execScript():
    
    Log.log(scriptCommand())

func add_setting(key: String, default_value: Variant, type: int, hint: int = PROPERTY_HINT_NONE, hint_string: String = ""):
    
    key = "exec/script/" + key
    
    if not ProjectSettings.has_setting(key):
        ProjectSettings.set(key, default_value)
    ProjectSettings.set_initial_value(key, default_value)
    ProjectSettings.add_property_info({name=key, type=type, hint=hint, hint_string=hint_string})

func get_setting(key: String) -> Variant:
    
    key = "exec/script/" + key
    
    if ProjectSettings.has_setting(key):
        return ProjectSettings.get_setting(key)
    return

func on_settings_changed():
    
    #Log.log("on settings changed")
    pass
    
