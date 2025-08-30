extends CanvasLayer

const HISTORY = 1920/4
const HEIGHT  = 20.0
const LINEW   = 4

var fps_history: Array[float] = []

var gradient:Gradient

func _ready():
    
    %Graph.position = Vector2(0,0)
    %Graph.size.y = HEIGHT
    %Graph.size.x = HISTORY*LINEW
    
    gradient = Gradient.new()
    gradient.add_point(0.0,  Color(0,0,0))
    gradient.add_point(0.49, Color(0.3,0.3,0.3))
    gradient.add_point(0.50, Color(0.7,0.3,0))
    gradient.add_point(0.99, Color(1,1,0))
    
func _process(delta: float):
    while fps_history.size() >= HISTORY:
        fps_history.pop_front()
    fps_history.push_back(clampf((HEIGHT-(1.0/delta))/HEIGHT, 0.0, 1.0))
    #fps_history.push_back(randf())
        
    if visible:
        %Graph.queue_redraw()
                
func drawGraph():
    if not fps_history.size(): return
    var lines  := PackedVector2Array()
    var colors := PackedColorArray()
    lines.resize(fps_history.size()*2)
    colors.resize(fps_history.size())
    for fps_index in fps_history.size():
        var fps = fps_history[fps_index]
        var ofs = (HISTORY-fps_history.size())*LINEW
        lines[fps_index*2]   = Vector2(fps_index*LINEW + ofs, 0)
        lines[fps_index*2+1] = Vector2(fps_index*LINEW + ofs, fps*HEIGHT)
        colors[fps_index]    = gradient.sample(fps)
    %Graph.draw_multiline_colors(lines, colors, 2.0)
