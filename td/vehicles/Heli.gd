class_name Heli
extends RigidBody3D

var player: Node3D :
    set(p): player = p; global_transform = p.global_transform
  
var speed        = 10.0
var maxSpeed     = 10.0
var ascendSpeed  = 15000
var steerSpeed   = 1000
var moveSpeed    = 30000

var MAX_ALTI     = 10.0
var contactCount = 0
var dashPower    = 200
var dash         = 0

func _ready():
    
    name = "Heli"
    applyCards()
    Post.subscribe(self)
    
func applyCards():
    
    var rangeCards = Info.permLvl(Card.PillRange)
    var powerCards = Info.permLvl(Card.PillPower)
    
    %LaserPointer.laserRange  = 3 + 2 * rangeCards
    %LaserPointer.laserDamage = pow(powerCards+1, 3)
    %LaserPointer.radiusBase = 0.04 + powerCards * 0.04
    
    dashPower = 170 + 30 * pow(powerCards+1, 1.5)
    
    %Collector.setRadius(17 + 17 * rangeCards)

func _physics_process(delta:float):
    
    if not player: return
    
    readInput()
    
    var dt = delta * speed / Engine.time_scale
    
    var af = 0.5 + global_position.y / MAX_ALTI
    
    var alti_soft = 1.0
    if global_position.y < 0.5 and %ascend.value < 0:
        alti_soft = global_position.y/0.5
    if global_position.y > MAX_ALTI-4.0 and %ascend.value > 0:
        alti_soft = -(global_position.y-MAX_ALTI)/4.0

    var fs = Vector2(%strafe.value, %forward.value).limit_length()

    var force = Vector3.ZERO
    force += player.transform.basis.x * fs.x * dt * moveSpeed
    force -= player.transform.basis.z * fs.y * dt * moveSpeed
    force += player.transform.basis.y * %ascend.value * dt * ascendSpeed * alti_soft
    
    apply_central_force(force)
    apply_torque(Vector3(0, -%steer.value*dt/Engine.time_scale*steerSpeed, 0))
    
    global_position.y = clamp(global_position.y, 0, MAX_ALTI)
    
    player.transform = transform

func _integrate_forces(state: PhysicsDirectBodyState3D):
    
    #state.linear_velocity = state.linear_velocity.limit_length(maxSpeed)

    var newContactCount = get_contact_count() 
    
    if contactCount == 0 and newContactCount == 1:
        Post.gameSound.emit(self, "land", state.get_contact_impulse(0).length())
    
    contactCount = newContactCount
    
    if contactCount > 1:
        Post.gameSound.emit(self, "hit", state.get_contact_impulse(1).length())
    
    state.linear_velocity = state.linear_velocity.limit_length(speed)
                                    
    if dash > 0.99 and %DashBlock.is_stopped():
        state.linear_velocity.x = 0
        state.linear_velocity.z = 0
        %DashBlock.start()
        %DashTimer.start()
        if global_position.y < 0.1:
            Post.gameSound.emit(self, "dash")
        else:
            Post.gameSound.emit(self, "dashAir")
    if dash < 0.96 and not %DashBlock.is_stopped():
        %DashBlock.stop()
        
    if not %DashTimer.is_stopped():
        if contactCount > 1:
            %DashTimer.stop()
        else:
            var dashDir = -global_basis.z
            apply_central_impulse(dashDir * dashPower * %DashTimer.time_left/%DashTimer.wait_time)
    
func readInput():

    dash = Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT)
    if Input.is_action_just_pressed("dash"):    dash = 1

    %ascend.zero()
    #%ascend.add(Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT))
    %ascend.add(-Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT))
    
    #if Input.is_action_pressed("alt_right"): %ascend.add(1)
    if Input.is_action_pressed("alt_down"):  %ascend.add(1)
    if Input.is_key_pressed(KEY_R):    %ascend.add( 1)
    if Input.is_key_pressed(KEY_F):    %ascend.add(-1)
    if Input.is_key_pressed(KEY_UP):   %ascend.add(1)
    if Input.is_key_pressed(KEY_DOWN): %ascend.add(-1)
    
    %forward.zero()
    %forward.add(-Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
    
    if Input.is_action_pressed("forward"):      %forward.add(1)
    if Input.is_action_pressed("backward"):     %forward.add(-1)
    
    %steer.zero()
    %steer.add(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X))
    if Input.is_action_pressed("steer_right"):  %steer.add(1)
    if Input.is_action_pressed("steer_left"):   %steer.add(-1)

    if Input.is_action_pressed("right"):        %steer.add(0.4)
    if Input.is_action_pressed("left"):         %steer.add(-0.4)
