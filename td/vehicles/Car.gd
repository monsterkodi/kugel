extends Node3D

var speed       := 10.0

var MIN_SPEED   := 10.0
var MAX_SPEED   := 30.0

var STEER_SPEED := 1.0

func _physics_process(delta:float):
    
    if not get_parent().is_processing_unhandled_input(): return
    
    readInput()
    
    var dt = delta * speed
    var fwd = %forward.value
    if fwd < 0: fwd *= 0.4

    var pt = get_parent_node_3d()
    pt.rotate_object_local(Vector3.UP, -%steer.value * delta * STEER_SPEED)
    pt.translate_object_local(Vector3.FORWARD * fwd  * dt)

    var nut = abs(%forward.value * 0.15) 
    %NutFL.rotation = Vector3.ZERO
    %NutFL.rotate_object_local(Vector3.FORWARD, nut)
    %NutFR.rotation = Vector3.ZERO
    %NutFR.rotate_object_local(Vector3.FORWARD, -nut)
    %NutBL.rotation = Vector3.ZERO
    %NutBL.rotate_object_local(Vector3.FORWARD, nut)
    %NutBR.rotation = Vector3.ZERO
    %NutBR.rotate_object_local(Vector3.FORWARD, -nut)
    
    %Body.position.y = 0.4 - nut * 0.25
    
    var st = %steer.value * delta * STEER_SPEED
    
    %WheelFL.rotate_object_local(Vector3.UP, fwd * dt * 0.3 * PI + st)
    %WheelFR.rotate_object_local(Vector3.UP, fwd * dt * 0.3 * PI - st)
    %WheelBL.rotate_object_local(Vector3.UP, fwd * dt * 0.3 * PI + st)
    %WheelBR.rotate_object_local(Vector3.UP, fwd * dt * 0.3 * PI - st)
    
    var sgn
    if sign(fwd) == -1: sgn = -1 
    else: sgn = 1 
    var sta = -%steer.value / (1.2*PI) * sgn
    %FL.rotation = Vector3.ZERO
    %FL.rotate_object_local(Vector3.UP, min(0, sta))
    %FR.rotation = Vector3.ZERO
    %FR.rotate_object_local(Vector3.UP, -min(0, -sta))
    sta = -%steer.value / (2.4*PI) * sgn
    %BL.rotation = Vector3.ZERO
    %BL.rotate_object_local(Vector3.UP, -min(0, sta))
    %BR.rotation = Vector3.ZERO
    %BR.rotate_object_local(Vector3.UP, min(0, -sta))

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
    %steer.add(Input.get_joy_axis(0, JOY_AXIS_LEFT_X))
    if Input.is_action_pressed("steer_right"):  %steer.add( 1)
    if Input.is_action_pressed("steer_left"):   %steer.add(-1)
    if Input.is_action_pressed("right"):        %steer.add( 1)
    if Input.is_action_pressed("left"):         %steer.add(-1)

    if Input.is_action_pressed("faster"):   faster()
    if Input.is_action_pressed("slower"):   slower()

func faster():
    
    speed *= 1.05; speed = clampf(speed, MIN_SPEED, MAX_SPEED); Log.log("speed", speed)
    
func slower():
    
    speed *= 0.95; speed = clampf(speed, MIN_SPEED, MAX_SPEED); Log.log("speed", speed)

func _unhandled_input(e: InputEvent):
    
    if not get_parent().is_processing_unhandled_input(): return
    
    if e is InputEventMouseButton:
        if e.button_index == MOUSE_BUTTON_WHEEL_UP:
            get_viewport().set_input_as_handled()
            faster()
        elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            get_viewport().set_input_as_handled()
            slower()
