class_name Drone extends Node3D
  
var steer        = 0.0
var speed        = 15.0

var MIN_SPEED    = 10.0
var MAX_SPEED    = 20.0
var MAX_ALTI     = 3.0

var STEER_SPEED  = 1.5

func _ready():
    %Body.position.y = 16.0

func _process(delta:float):
    
    readInput()
    
    var dt = delta * speed
    
    var fs = Vector2(%strafe.value, %forward.value).limit_length()

    rotate_object_local(Vector3.UP, -steer * delta * STEER_SPEED)
    translate_object_local(Vector3.FORWARD * fs.y * dt)
    translate_object_local(Vector3.RIGHT   * fs.x * dt)
    
    %Body.position.y = lerp(%Body.position.y, MAX_ALTI, 0.05)

func readInput():

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
    
    speed *= 1.05; speed = clampf(speed, MIN_SPEED, MAX_SPEED)
    
func slower():
    
    speed *= 0.95; speed = clampf(speed, MIN_SPEED, MAX_SPEED)

func _unhandled_input(e: InputEvent):
    
    if e is InputEventMouseButton:
        if e.button_index == MOUSE_BUTTON_WHEEL_UP:
            get_viewport().set_input_as_handled()
            faster()
        elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            get_viewport().set_input_as_handled()
            slower()
