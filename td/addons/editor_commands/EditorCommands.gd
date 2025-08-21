@tool
extends EditorPlugin

class EditorCommands extends EditorDebuggerPlugin:
    
    var plugin
    
    func _has_capture(capture: String) -> bool:
        return capture == "editor"
        
    func _capture(message: String, data: Array, session_id: int) -> bool:
        if message == "editor:command":
            for cmd in data:
                if cmd == "distraction_free_mode":
                    EditorInterface.distraction_free_mode = not EditorInterface.distraction_free_mode
                    return true
                if cmd == "toggle_bottom_panel":
                    var bp = plugin.controlWithName("EditorBottomPanel")
                    bp.visible = !bp.visible
                    return true
                if cmd == "toggle_output":
                    #plugin.toggleBottomPanelChildWithName("EditorLog")
                    var event = plugin.parseKeyEvent(cmd)
                    Input.parse_input_event(event)
                    return true
        if message == "editor:shortcut":
            for cmd in data:
                Input.parse_input_event(plugin.parseKeyEvent(cmd))
            return true
        return false
        
var debugger = EditorCommands.new()

func parseKeyEvent(text:String) -> InputEventKey:
    var event = InputEventKey.new()
    event.pressed = true
    var parts = text.split("+")
    for part in parts:
        part = part.strip_edges().to_lower()
        match part:
            "ctrl", "ctrl":                     event.ctrl_pressed  = true
            "shift":                            event.shift_pressed = true
            "alt", "option":                    event.alt_pressed   = true
            "meta", "command", "cmd", "super":  event.meta_pressed  = true
            _: event.keycode = OS.find_keycode_from_string(part)
    return event

func toggleBottomPanelChildWithName(name:String):
    
    var bp = controlWithName("EditorBottomPanel")
    bp.visible = true
    var lo = controlWithName("EditorLog")
    hideAllBottomPanelChildren()
    lo.visible = true #!lo.visible
    
func allBottomPanelChildren():
    var bp = controlWithName("EditorBottomPanel")
    var children = bp.get_child(0).get_children()
    var buttons = children.pop_back()
    return children
    
func allBottomPanelButtons():
    var bp = controlWithName("EditorBottomPanel")
    var children = bp.get_child(0).get_children()
    var buttons = children[-1].get_child(1).get_child(0).get_children()
    return buttons
        
func hideAllBottomPanelChildren():
    
    for child in allBottomPanelChildren():
        child.visible = false

func controlWithName(name:String) -> Control:
    
    var children := EditorInterface.get_base_control().get_children()
    while not children.is_empty():
        var node := children.pop_back() as Node
        if node.name.find(name) >= 0:
            print(node)
            return node
        else:
            children.append_array(node.get_children())
    return null
        
func _enter_tree() -> void:
    add_debugger_plugin(debugger)
    debugger.plugin = self
    
    #controlWithName("EditorBottomPanel").get_child(0).get_child(-1).print_tree_pretty()
    #for button in allBottomPanelButtons():
        #Log.log(button, button.text, button.shortcut)

func _exit_tree() -> void:
    remove_debugger_plugin(debugger)

var editor_view_hierarchy = '''

        EditorTitleBar
           MenuBar
              Scene
              Project
              Debug
              Editor
              Help
           EditorMainScreenButtons
              2D
              3D
              Script
              Game
              AssetLib
           EditorRunBar
                EditorRunNative
                
            Scene
                SceneTreeEditor
            FileSystem
                        FileSystemList
                        EditorSceneTabs
                        EditorMainScreen
                        MainScreen
                            CanvasItemEditor
                            Node3DEditor
                                DirectionalLight3D
                                WorldEnvironment
                                ScriptEditor
                                GameView
                            EditorAssetLibrary
                EditorBottomPanel
                        EditorLog
                        EditorDebuggerNode
                                    Stack Trace
                                    Errors
                                    Evaluator
                                    Profiler
                                    Visual Profiler
                                    Monitors
                                    Video RAM
                                    Misc
                                    Network Profiler
                        AnimationPlayerEditor
                        FindInFilesPanel
                        EditorAudioBuses
                        AnimationTreeEditor
                        ResourcePreloaderEditor
                        ShaderFileEditor
                        SpriteFramesEditor
                        ThemeEditor
                        TileSetEditor
                        TileMapLayerEditor
                        ReplicationEditor
                        GridMapEditor
                    Inspector
                    Node
                    History
            EditorPropertyPath
            Options
                EditorInspectorCategory
            Resources
            Patches
            Features
            Encryption
            Scripts
            
     DependencyEditor
        Dependencies
     EditorSettingsDialog
           General
           Shortcuts
     ProjectSettingsEditor
           General
           Input Map
           Localization
           Globals
           Plugins
           Import Defaults
     EditorCommandPalette
     EditorLayoutsDialog
     EditorNativeShaderSourceVisualizer
     OrphanResourcesDialog
     MeshInstance3DEditor
     MeshLibraryEditor
     MultiMeshEditor
     TextureRegionEditor
     EditorFileDialog
     Camera2DEditor
     CollisionShape2DEditor
     Cast2DEditor
     Skeleton2DEditor
     Sprite2DEditor
     CSGShapeEditor
     AudioStreamInteractiveTransitionEditor
     NavigationLink2DEditor
     NavigationRegion3DEditor
     EditorQuickOpenDialog
'''
