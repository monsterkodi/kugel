class_name LevelButton
extends Button

@onready var viewport: SceneViewport = %Viewport

func setScene(scene:PackedScene):
    
    text = scene.resource_path.get_file().get_basename().replace("Level", "")
    viewport.setScene(scene)
    
func setColor(color:Color):
    
    var sb = get_theme_stylebox("normal", "Button").duplicate()
    sb.bg_color = color * 0.5
    add_theme_stylebox_override("normal", sb)
    add_theme_color_override("font_color", color)
    
func setSize(sceneSize:Vector2i):
    
    viewport.size = sceneSize
