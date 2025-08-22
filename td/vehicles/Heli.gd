extends Node3D
  
var steer        = 0.0
var speed        = 10.0

var MIN_SPEED    = 10.0
var MAX_SPEED    = 20.0

var STEER_SPEED  = 1.5
var ASCEND_SPEED = 2.0
var MAX_ALTI     = 3.0

func _physics_process(delta:float):
    
    readInput()
    
    var pt = get_parent_node_3d()
    var dt = delta * speed
    var af = pt.position.y / MAX_ALTI
    
    var alti_soft = 1.0
    if pt.position.y < 0.1 and %ascend.value < 0:
        alti_soft = pt.position.y/0.1
    if pt.position.y > MAX_ALTI-2.0 and %ascend.value > 0:
        alti_soft = -(pt.position.y-MAX_ALTI)/2.0

    var fs = MathUtils.max_length(Vector2(%strafe.value, %forward.value), 1.0)

    pt.rotate_object_local(Vector3.UP, -steer * delta * STEER_SPEED)
    pt.translate_object_local(Vector3.FORWARD * fs.y * dt * af)
    pt.translate_object_local(Vector3.RIGHT   * fs.x  * dt * af)
    pt.translate_object_local(Vector3.UP * %ascend.value * delta * ASCEND_SPEED * alti_soft)
    pt.position.y = clamp(pt.position.y, 0, MAX_ALTI)

func readInput():

    %ascend.zero()
    %ascend.add(Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT))
    %ascend.add(-Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT))
    
    if Input.is_action_pressed("alt_down"): %ascend.add( 1)
    if Input.is_key_pressed(KEY_R): %ascend.add( 1)
    if Input.is_key_pressed(KEY_F): %ascend.add(-1)
    
    %forward.zero()
    %forward.add(-Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
    %forward.add(-Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
    
    if Input.is_action_pressed("forward"):      %forward.add(1)
    if Input.is_action_pressed("backward"):     %forward.add(-1)
    if Input.is_key_pressed(KEY_UP):            %forward.add(1)
    if Input.is_key_pressed(KEY_DOWN):          %forward.add(-1)
    
    %strafe.zero()
    %strafe.add(Input.get_joy_axis(0, JOY_AXIS_LEFT_X))
    if Input.is_action_pressed("right"):        %strafe.add(1)
    if Input.is_action_pressed("left"):         %strafe.add(-1)
    
    steer  = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
    if Input.is_action_pressed("steer_right"):  steer += 1
    if Input.is_action_pressed("steer_left"):   steer -= 1

    if Input.is_action_pressed("faster"):   faster()
    if Input.is_action_pressed("slower"):   slower()

func faster():
    
    speed *= 1.05; speed = clampf(speed, MIN_SPEED, MAX_SPEED)#; Log.log("speed", speed)
    
func slower():
    
    speed *= 0.95; speed = clampf(speed, MIN_SPEED, MAX_SPEED)#; Log.log("speed", speed)

func _unhandled_input(e: InputEvent):
    
    if e is InputEventMouseButton:
        if e.button_index == MOUSE_BUTTON_WHEEL_UP:
            get_viewport().set_input_as_handled()
            faster()
        elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            get_viewport().set_input_as_handled()
            slower()
