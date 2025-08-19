extends AnimatableBody3D

var speed     = 3

var MIN_SPEED = 3
var MAX_SPEED = 6

var STEER_SPEED  = 1

func _process(delta:float):
    
    if not get_parent().inputEnabled: return
    
    readInput()
    
    var dt = delta * speed

    var fs = MathUtils.max_length(Vector2(%strafe.value, %forward.value), 1.0)
    var pt = get_parent_node_3d()
    pt.rotate_object_local(Vector3.UP, -%steer.value * delta * STEER_SPEED)
    
    var translate = transform.basis.x * fs.x * dt - transform.basis.z * fs.y  * dt
    #pt.translate_object_local(translate)
    
    var collision = move_and_collide(translate, false)
    if collision:
        Log.log("collision", collision)
        
    #pt.translate_object_local(Vector3.RIGHT * fs.x * dt)
    #pt.translate_object_local(Vector3.FORWARD * fs.y  * dt)

func readInput():
    
    %forward.zero()
    %forward.add(-Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
    %forward.add(-Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
    %forward.add( Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT))
    %forward.add(-Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT))
    
    if Input.is_action_pressed("forward"):      %forward.add( 1)
    if Input.is_action_pressed("backward"):     %forward.add(-1)
    if Input.is_key_pressed(KEY_UP):            %forward.add( 1)
    if Input.is_key_pressed(KEY_DOWN):          %forward.add(-1)
    
    %steer.zero()
    %steer.add(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X))
    if Input.is_action_pressed("steer_right"):  %steer.add( 1)
    if Input.is_action_pressed("steer_left"):   %steer.add(-1)

    %strafe.zero()
    %strafe.add(Input.get_joy_axis(0, JOY_AXIS_LEFT_X))
    if Input.is_action_pressed("right"):        %strafe.add(1)
    if Input.is_action_pressed("left"):         %strafe.add(-1)

    if Input.is_action_pressed("faster"):   faster()
    if Input.is_action_pressed("slower"):   slower()

func faster():
    
    speed *= 1.1; speed = clampf(speed, MIN_SPEED, MAX_SPEED); Log.log("speed", speed)
    
func slower():
    
    speed *= 0.9; speed = clampf(speed, MIN_SPEED, MAX_SPEED); Log.log("speed", speed)

func _input(e: InputEvent):
    
    if not get_parent().inputEnabled: return
    
    if e is InputEventMouseButton:
        if e.button_index == MOUSE_BUTTON_WHEEL_UP:
            faster()
        elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            slower()
