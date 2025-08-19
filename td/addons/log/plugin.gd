@tool
extends EditorPlugin

func _enter_tree():
    
    Log.setup_settings()
    Log.rebuild_config()
    ProjectSettings.settings_changed.connect(on_settings_changed)
    
    var outputPanel = find_output_panel(get_tree().root)
    if outputPanel:
        outputPanel.meta_clicked.connect(on_meta_clicked)
        
func on_meta_clicked(meta:String):
    
    var json = JSON.parse_string(meta)
    EditorInterface.edit_script(load(json.src), int(json.line))
    EditorInterface.set_main_screen_editor("Script")

func find_output_panel(node: Node) -> Node:
    
    var editor_log: Node = find_editor_log(node)
    if editor_log:
        return editor_log.find_child("*RichTextLabel*", true, false)
    return null

func find_editor_log(node: Node) -> Node:
    
    if node.name.contains("EditorLog"):
        return node
    for child in node.get_children():
        var found: Node = find_editor_log(child)
        if found:
            return found
    return null

func on_settings_changed():
    
    Log.rebuild_config()
