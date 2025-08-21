@tool
extends EditorPlugin

const SCENE_TOP_BAR: PackedScene = preload("res://addons/script-name-on-top/topbar.tscn")
const MAX_RECENT_ITEMS := 20
const COLOR_BUTTONS := Color8(255, 255, 0, 255)

var _editor_interface: EditorInterface
var _script_editor: ScriptEditor
var _script_editor_menu: Control
var _the_tree: Tree
var _current_editor: ScriptEditorBase
var _scripts_panel_collapse: PopupMenu
var _scripts_panel: Control

var _recently_opened: Array[String] = []
var _extension_top_bar: MenuButton
var _extension_popup: PopupMenu

func _enter_tree() -> void:
    _init_vars()

func _exit_tree() -> void:
    if is_instance_valid(_extension_top_bar):
        _extension_top_bar.queue_free()

func _ready() -> void:
    while _script_editor_menu.get_children().size() < 13:
        await get_tree().process_frame

    for i in _script_editor_menu.get_children():
        i.size_flags_horizontal = 0

    _add_extension_top_bar()

    _build_recent_scripts_list()
    _editing_something_new(_script_editor.get_current_editor())

func _init_vars() -> void:
    _editor_interface = get_editor_interface()
    _script_editor = _editor_interface.get_script_editor()
    _script_editor_menu = _script_editor.get_child(0).get_child(0)
    var scene_tree_dock = _editor_interface.get_base_control().find_children("*", "SceneTreeDock", true, false)[0]
    var scene_tree_editor = scene_tree_dock.find_children("*", "SceneTreeEditor", true, false)[0]
    _the_tree = scene_tree_editor.get_child(0)
    _scripts_panel = _script_editor.get_child(0).get_child(1).get_child(0)
    _scripts_panel_collapse = _script_editor_menu.get_child(0).get_popup()

func _add_extension_top_bar() -> void:
    _extension_top_bar = SCENE_TOP_BAR.instantiate()
    _script_editor_menu.add_child(_extension_top_bar)
    _script_editor_menu.move_child(_extension_top_bar, -8)
    
    _extension_popup = _extension_top_bar.get_popup()

    _extension_top_bar.pressed.connect(_build_recent_scripts_list)
    _extension_popup.id_pressed.connect(_on_recent_submenu_pressed)
    _extension_popup.window_input.connect(_on_recent_submenu_window_input)

func _process(_delta: float) -> void:
    if _current_editor != _script_editor.get_current_editor():
        _current_editor = _script_editor.get_current_editor()
        _editing_something_new(_current_editor)

    _tree_recursive_highlight(_the_tree.get_root())
    
    _script_editor_menu.get_child(-7).set_text("")
    _script_editor_menu.get_child(-6).set_text("")
    _script_editor_menu.get_child(-6).modulate = Color(1,1,1,0.5)
    _script_editor_menu.get_child(-7).modulate = Color(1,1,1,0.5)

func _build_recent_scripts_list() -> void:
    _extension_popup.clear()
    for i in _recently_opened.size():
        _extension_popup.add_item(_recently_opened[i])

    if _recently_opened.size() == 0:
        _extension_popup.visible = false

func _add_recent_script_to_array(recent_string: String) -> void:
    var find_existing: int = _recently_opened.find(recent_string)
    if find_existing == -1:
        _recently_opened.push_front(recent_string)
        if _recently_opened.size() > MAX_RECENT_ITEMS:
            _recently_opened.pop_back()
    else:
        _recently_opened.push_front(_recently_opened.pop_at(find_existing))

func _editing_something_new(current_editor: ScriptEditorBase) -> void:
    if not is_instance_valid(_extension_top_bar): return

    var new_text: String = ""
    var current_script = _script_editor.get_current_script()

    if is_instance_valid(current_script):
        new_text = current_script.resource_path.replace("res://", "")
        _add_recent_script_to_array(new_text)
        _extension_top_bar.modulate = Color(1,1,1,1)
    else:
        _extension_top_bar.modulate = Color(0,0,0,0) # Make it invisible if not using it

    _extension_top_bar.text = new_text
    #_extension_top_bar.tooltip_text = new_text

func _is_main_screen_visible(screen) -> bool:
    # 0 = 2D, 1 = 3D, 2 = Script, 3 = AssetLib
    return _editor_interface.get_editor_main_screen().get_child(2).visible

func _tree_recursive_highlight(item) -> void:
    while item != null:
        item.set_custom_bg_color(0, Color(0,0,0,0))

        # Set color of only Script Buttons, not the Visibility Buttons
        for i in item.get_button_count(0):
            var tooltip_text = item.get_button_tooltip_text(0,i)

            item.set_button_color(0, i, Color(1,1,1,1))

            if not tooltip_text.ends_with(".gd") or not _is_main_screen_visible(2) == true:
                continue

            item.set_button_color(0, i, Color(1,1,1,1))

            # Change the script tooltip into a script path
            var script_path = tooltip_text.get_slice(": ", 1)
            script_path = script_path.trim_suffix("This script is currently running in the editor.")
            script_path = script_path.strip_escapes()

            var current_script = _script_editor.get_current_script()
            if current_script == null or not script_path == current_script.resource_path:
                continue

            item.set_button_color(0, i, COLOR_BUTTONS)

        _tree_recursive_highlight(item.get_first_child())
        item = item.get_next()

func _on_recent_submenu_window_input(event: InputEvent) -> void:
    if not event is InputEventMouseButton or not event.button_index == MOUSE_BUTTON_RIGHT:
        return

    if event.pressed == true:
        # Erase item from list
        _recently_opened.erase(_extension_popup.get_item_text(_extension_popup.get_focused_item()))
        _build_recent_scripts_list()
        if _recently_opened.size() > 0:
            # Refresh and display shrunken list correctly
            _extension_top_bar.show_popup()
        else:
            # Don't bother opening an empty menu
            _extension_popup.visible = false
    else:
        # Prevent switching to an item upon releasing right click
        _extension_popup.hide_on_item_selection = false
        _extension_popup.id_pressed.disconnect(_on_recent_submenu_pressed)
        await get_tree().process_frame
        _extension_popup.hide_on_item_selection = true
        _extension_popup.id_pressed.connect(_on_recent_submenu_pressed)


func _on_recent_submenu_pressed(pressedID: int) -> void:
    var recent_string: String = _extension_popup.get_item_text(pressedID)
    var load_script: Resource = load(recent_string)
    if load_script != null:
        _editor_interface.edit_script(load_script)
