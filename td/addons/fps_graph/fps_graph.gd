extends CanvasLayer

const HISTORY_NUM_FRAMES = 500

var fps_history: Array[float] = []

var gradient:Gradient

func _ready():
    gradient = Gradient.new()
    gradient.add_point(0.0,  Color(0,0,0))
    gradient.add_point(0.4,  Color(0.3,0.3,0.3))
    gradient.add_point(0.5,  Color(0.7,0.3,0))
    gradient.add_point(0.99, Color(1,1,0))
    
    #for x in range(500): fps_history.push_back(x/500.0)

func _process(delta: float):
    while fps_history.size() >= HISTORY_NUM_FRAMES:
        fps_history.pop_front()
    fps_history.push_back(clampf((60.0-(1.0/delta))/60.0, 0.0, 1.0))
        
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
        var ofs = (1000-fps_history.size()*2)
        lines[fps_index*2]   = Vector2(fps_index*2 + ofs, 0)
        lines[fps_index*2+1] = Vector2(fps_index*2 + ofs, fps*120)
        colors[fps_index]    = gradient.sample(fps)
    %Graph.draw_multiline_colors(lines, colors, 2.0)
