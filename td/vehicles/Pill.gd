class_name Pill extends RigidBody3D

var player: Node3D
var speed = 6
var dash  = 0

var MIN_SPEED = 3
var MAX_SPEED = 6

var mouseRot   = 0.0
var mouseDelta = Vector2.ZERO
var dashDir    = Vector3.FORWARD

func _ready():
    
    name = "Pill"
    global_position = Vector3.UP
    applyCards()
    Post.subscribe(self)
    
func applyCards():
    
    %LaserPointer.laserRange  = 3 + 2 * Info.permLvl(Card.PillRange)
    %LaserPointer.laserDamage = 1 + pow(Info.permLvl(Card.PillPower), 2)
    
    %Collector.setRadius(7 + 7 * Info.permLvl(Card.PillRange))
    
    #Log.log("pill", %LaserPointer.laserDamage, %LaserPointer.laserRange, %Collector.radius)

func _physics_process(delta:float):
    
    if not player: return
    
    var dt = delta * speed / Engine.time_scale
    
    readInput(dt)

    var fs = Vector2(%strafe.value, %forward.value).limit_length()
        
    var force = Vector3.ZERO
    force += player.transform.basis.x * fs.x * dt * 1000
    force -= player.transform.basis.z * fs.y * dt * 1000
    
    apply_central_force(force)
    apply_torque(Vector3(0, -%steer.value*dt*100, 0))
        
    apply_torque(Vector3(0, -mouseDelta.x*dt*1.5, 0))
    mouseDelta = Vector2.ZERO

    calcDashDir(dt)
     
    %LaserPointer.setDir(dashDir)

    player.transform = transform
    
func _integrate_forces(state: PhysicsDirectBodyState3D):
   
    var contactCount = get_contact_count() 
    
    state.linear_velocity = state.linear_velocity.limit_length(speed)
    
    if Input.is_action_pressed("jump") and %JumpBlock.is_stopped():
        if contactCount > 0:
            %JumpTimer.start()
            %jump.play()
            
    if not %JumpTimer.is_stopped():
        apply_central_impulse(Vector3.UP * 100 * %JumpTimer.time_left/%JumpTimer.wait_time)
                    
    if dash > 0.99 and %DashBlock.is_stopped():
        state.linear_velocity.x = 0
        state.linear_velocity.z = 0
        %DashBlock.start()
        %DashTimer.start()
        if global_position.y < 0.1:
            %dash.set_volume_linear(0.2)
        else:
            %dash.set_volume_linear(0.05)
        %dash.play()
    if dash < 0.96 and not %DashBlock.is_stopped():
        %DashBlock.stop()
        
    if not %DashTimer.is_stopped():
        if contactCount > 1:
            %DashTimer.stop()
        else:
            apply_central_impulse(dashDir * 200 * %DashTimer.time_left/%DashTimer.wait_time)

func calcDashDir(delta:float):
    
    var dt  = delta
    var dir = Vector3.ZERO
    
    if mouseDelta.x != 0: 
        mouseRot += mouseDelta.x*0.0005
        mouseRot = clampf(mouseRot,-PI, PI)
    mouseRot = lerpf(mouseRot, 0.0, dt)

    var xinp = Input.get_joy_axis(0, JOY_AXIS_LEFT_X) #+ Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
    var yinp = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) #+ Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
    
    const deadzone = 0.25
    if absf(xinp) < deadzone: xinp = 0
    if absf(yinp) < deadzone: yinp = 0

    if Input.is_key_pressed(KEY_UP):    yinp -= dt*60 
    if Input.is_key_pressed(KEY_DOWN):  yinp += dt*60 
    if Input.is_key_pressed(KEY_A):     xinp -= dt*60 
    if Input.is_key_pressed(KEY_D):     xinp += dt*60 
    if Input.is_key_pressed(KEY_W):     yinp -= dt*60 
    if Input.is_key_pressed(KEY_S):     yinp += dt*60 
    
    if xinp or yinp:
        if absf(xinp) > 0: dir += xinp  * global_transform.basis.x
        if absf(yinp) > 0: dir += yinp  * global_transform.basis.z
        dir = dir.normalized()
    else:
        dir = -global_basis.z
    
    if Input.is_key_pressed(KEY_LEFT):   mouseRot -= dt
    if Input.is_key_pressed(KEY_RIGHT):  mouseRot += dt
    
    mouseRot += Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) * dt * 0.5
    
    if mouseRot:
        dir = dir.rotated(Vector3.UP, -mouseRot)
    
    dashDir = lerp(dashDir, dir, dt*0.2)  
    
func readInput(delta:float):
    
    var dt = 1
    
    %forward.zero()
    %forward.add(-Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)*dt)
    #%forward.add(-Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
    dash = Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT)
    if Input.is_action_just_pressed("dash"):    dash = 1
    
    if Input.is_action_pressed("forward"):      %forward.add( dt)
    if Input.is_action_pressed("backward"):     %forward.add(-dt)
    if Input.is_key_pressed(KEY_UP):            %forward.add( dt)
    if Input.is_key_pressed(KEY_DOWN):          %forward.add(-dt)
    
    %steer.zero()
    %steer.add(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)*dt)
    if Input.is_action_pressed("steer_right"):  %steer.add( dt)
    if Input.is_action_pressed("steer_left"):   %steer.add(-dt)
    
    %strafe.zero()
    %strafe.add(Input.get_joy_axis(0, JOY_AXIS_LEFT_X)*dt)
    if Input.is_action_pressed("right"):        %strafe.add( dt)
    if Input.is_action_pressed("left"):         %strafe.add(-dt)

    #if Input.is_action_pressed("faster"): faster()
    #if Input.is_action_pressed("slower"): slower()

#func faster():
    #
    #speed *= 1.01; speed = clampf(speed, MIN_SPEED, MAX_SPEED); Log.log("speed", speed)
    
#func slower():
    #
    #speed *= 0.99; speed = clampf(speed, MIN_SPEED, MAX_SPEED); Log.log("speed", speed)

func _input(event: InputEvent):
    
    if event is InputEventMouseMotion:
        mouseDelta = event.relative

#func _unhandled_input(event: InputEvent):
    #
    #if event is InputEventMouseButton:
        #if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            #get_viewport().set_input_as_handled()
            #faster()
        #elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            #get_viewport().set_input_as_handled()
            #slower()
            
