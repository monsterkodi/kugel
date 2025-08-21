extends Camera3D

var TILT_SPEED   := 1.0
var STEER_SPEED  := 0.2 
var MOVE_SPEED   := 1.0
var STRAFE_SPEED := 1.0
var ASCEND_SPEED := 0.2

var MIN_ALTI     := 0.5
var MAX_ALTI     := 50.0
var MAX_SPEED    := 10.0
var FCT_ALTITUDE := 10.0

var fa           := 1.0
var speed        := 3.0
var forward      := 0.0
var strafe       := 0.0
var ascend       := 0.0
var steer        := 0.0
var tilt         := 0.0

func _process(delta:float):
    
    if not current: return
    
    readInput()
    
    var dt = delta * speed
    fa = 1 + FCT_ALTITUDE * (transform.origin.y-MIN_ALTI)/(MAX_ALTI-MIN_ALTI)
    
    var pt = get_parent_node_3d()
    pt.translate_object_local(Vector3.FORWARD * forward  * dt * MOVE_SPEED   * fa) 
    pt.translate_object_local(Vector3.RIGHT   * strafe   * dt * STRAFE_SPEED * fa)
    
    steer_delta( steer  * dt * STEER_SPEED)
    ascend_delta(ascend * dt * ASCEND_SPEED)
    tilt_delta(  tilt   * delta * TILT_SPEED)
    
func steer_delta(delta:float):
    
    var pt = get_parent_node_3d()
    pt.transform.basis = pt.transform.basis.rotated(pt.transform.basis.y, -delta) 
    
func tilt_delta(delta:float):
    
    transform.basis = transform.basis.rotated(transform.basis.x, delta)
    
func pan_delta(delta:Vector2):
    
    var pt = get_parent_node_3d()
    pt.translate_object_local(Vector3.LEFT    * delta.x * fa)
    pt.translate_object_local(Vector3.FORWARD * delta.y * fa)

func strafe_delta(delta:float):
    
    var pt = get_parent_node_3d()
    pt.translate_object_local(Vector3.RIGHT   * delta)

func ascend_delta(delta:float):
    
    transform.origin.y = clamp(transform.origin.y+delta*transform.origin.y, MIN_ALTI, MAX_ALTI)
    
func readInput():
    
    if Input.is_key_pressed(KEY_META): return
    
    forward = -Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
    if Input.is_action_pressed("forward"):      forward += 1
    if Input.is_action_pressed("backward"):     forward -= 1
    
    strafe = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
    if Input.is_action_pressed("right"):        strafe += 1
    if Input.is_action_pressed("left"):         strafe -= 1

    steer = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
    if Input.is_action_pressed("steer_right"):  steer += 1
    if Input.is_action_pressed("steer_left"):   steer -= 1
        
    tilt = -Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
    if Input.is_action_pressed("tilt_up"):      tilt += 0.5
    if Input.is_action_pressed("tilt_down"):    tilt -= 0.5
    
    ascend = -Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT) + Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT)
    if Input.is_action_pressed("ascend"):       ascend += 1
    if Input.is_action_pressed("descend"):      ascend -= 1
    
    if Input.is_action_pressed("faster"):   faster()
    if Input.is_action_pressed("slower"):   slower()
    
func faster():
    
    speed *= 1.05; speed = clampf(speed, 1, MAX_SPEED); Log.log("speed", speed)
    
func slower():
    
    speed *= 0.95; speed = clampf(speed, 1, MAX_SPEED); Log.log("speed", speed)
    
func dbg(msg: Variant, msg2: Variant = Log.nil, msg3: Variant = Log.nil, msg4: Variant = Log.nil, msg5: Variant = Log.nil, msg6: Variant = Log.nil, msg7: Variant = Log.nil):
    if false:
        Log.lvl(1, msg, msg2, msg3, msg4, msg5, msg6, msg7)    
 
func _input(e: InputEvent):
    
    if not current: return
    
    if e is InputEventMouseMotion:
        if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
            dbg("mouse drag left", e)
        if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
            dbg("mouse drag right", e)
            steer_delta(e.relative.x * 0.001)
            tilt_delta(-e.relative.y * 0.001)
        if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
            dbg("mouse drag middle", e)
            pan_delta(e.relative * 0.001)
        if e.button_mask == 0:    
            dbg("mouse move", e.position)
            
    elif e is InputEventMouseButton:
        if e.button_index == MOUSE_BUTTON_WHEEL_UP:
            dbg("wheel up", e)
            faster()
        elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            dbg("wheel down", e)
            slower()
            
    elif e is InputEventPanGesture:
        if Input.is_key_pressed(KEY_META):
            dbg("strafe dist", e)
            strafe_delta(e.delta.x * 0.01)
            ascend_delta(e.delta.y * 0.01)
        elif Input.is_key_pressed(KEY_ALT):
            dbg("pan", e)
            pan_delta(e.delta * 0.01)
        elif Input.is_key_pressed(KEY_SHIFT):
            dbg("dist", e)
            ascend_delta(e.delta.y * 0.01)
        else:
            dbg("steer tilt", e)
            steer_delta( e.delta.x * 0.01)
            tilt_delta(-e.delta.y * 0.01)
        
    elif e is InputEventMagnifyGesture:
        dbg("magnify", e)
        ascend_delta((1.0 - e.factor))
        
    elif e is InputEventJoypadMotion:
        dbg(e.get_class(), {"axis": e.axis, "axis_value": e.axis_value})
        
    elif e is InputEventJoypadButton:
        dbg(e.get_class(), {"button_index": e.button_index, "pressed": e.pressed})
    else:
        dbg("EVENT", e)
                  
