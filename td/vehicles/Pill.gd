class_name Pill extends RigidBody3D

var player: Node3D
var speed = 6
var dash  = 0

var MIN_SPEED = 3
var MAX_SPEED = 6

var mouseDelta = Vector2.ZERO
var dashDir = Vector3.FORWARD

func _physics_process(delta:float):
    
    readInput(delta)
    
    var dt = delta * speed

    var fs = MathUtils.max_length(Vector2(%strafe.value, %forward.value), 1.0)
        
    var force = Vector3.ZERO
    force += player.transform.basis.x * fs.x * dt * 1000
    force -= player.transform.basis.z * fs.y * dt * 1000
    
    apply_central_force(force)
    apply_torque(Vector3(0, -%steer.value*delta*800, 0))
        
    apply_torque(Vector3(0, -mouseDelta.x*0.3, 0))
    mouseDelta = Vector2.ZERO

    player.transform = transform
    
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
   
    var contactCount = get_contact_count() 
    
    state.linear_velocity = MathUtils.max_length(state.linear_velocity, speed)
    if Input.is_action_pressed("alt_down") and %JumpTimer.is_stopped():
        if contactCount > 0:
            apply_central_impulse(Vector3.UP*60)
            %JumpTimer.start()
                    
    if dash > 0.99 and %DashBlock.is_stopped():
        linear_velocity = Vector3.ZERO
        %DashBlock.start()
        %DashTimer.start()
        calcDashDir()
    if dash < 0.96 and not %DashBlock.is_stopped():
        %DashBlock.stop()
        
    if not %DashTimer.is_stopped():
        if contactCount > 1:
            %DashTimer.stop()
        else:
            apply_central_impulse(dashDir * 300 * %DashTimer.time_left/%DashTimer.wait_time)
    else:
        calcDashDir()
     
    %LaserPointer.setDir(dashDir)

func calcDashDir():
    
    var dir = linear_velocity
    dir.y = 0
    dir = dir.limit_length()
    var xinp = Input.get_joy_axis(0, JOY_AXIS_LEFT_X) + Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
    var yinp = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) + Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
    const deadzone = 0.25
    if absf(xinp) > deadzone: dir += xinp  * global_transform.basis.x
    if absf(yinp) > deadzone: dir += yinp  * global_transform.basis.z
    
    dir = dir.normalized()
    dashDir = lerp(dashDir, dir, 0.1)  
    
func readInput(delta:float):
    
    var dt = delta*60.0
    
    %forward.zero()
    %forward.add(-Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
    %forward.add(-Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
    dash = Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT)
    
    if Input.is_action_pressed("forward"):      %forward.add( 1)
    if Input.is_action_pressed("backward"):     %forward.add(-1)
    if Input.is_key_pressed(KEY_UP):            %forward.add( 1)
    if Input.is_key_pressed(KEY_DOWN):          %forward.add(-1)
    
    %steer.zero()
    %steer.add(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)*dt)
    if Input.is_action_pressed("steer_right"):  %steer.add( dt)
    if Input.is_action_pressed("steer_left"):   %steer.add(-dt)
    
    %strafe.zero()
    %strafe.add(Input.get_joy_axis(0, JOY_AXIS_LEFT_X))
    if Input.is_action_pressed("right"):        %strafe.add(1)
    if Input.is_action_pressed("left"):         %strafe.add(-1)

    if Input.is_action_pressed("faster"): faster()
    if Input.is_action_pressed("slower"): slower()

func faster():
    
    speed *= 1.01; speed = clampf(speed, MIN_SPEED, MAX_SPEED); Log.log("speed", speed)
    
func slower():
    
    speed *= 0.99; speed = clampf(speed, MIN_SPEED, MAX_SPEED); Log.log("speed", speed)

func _input(event: InputEvent) -> void:
    
    if event is InputEventMouseMotion:
        mouseDelta = event.relative

func _unhandled_input(event: InputEvent) -> void:
    
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            get_viewport().set_input_as_handled()
            faster()
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            get_viewport().set_input_as_handled()
            slower()
            
