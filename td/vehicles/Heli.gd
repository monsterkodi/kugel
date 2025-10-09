class_name Heli
extends RigidBody3D

var player: Node3D :
    set(p): player = p; global_transform = p.global_transform
  
var speed        = 10.0
var maxSpeed     = 10.0
var ascendSpeed  = 5000
var steerSpeed   = 1500
var moveSpeed    = 30000

var MAX_ALTI     = 10.0

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
    
    %Collector.setRadius(17 + 17 * rangeCards)

func _physics_process(delta:float):
    
    if not player: return
    
    readInput()
    
    var dt = delta * speed / Engine.time_scale
    
    var af = 0.5 + position.y / MAX_ALTI
    
    var alti_soft = 1.0
    if position.y < 0.1 and %ascend.value < 0:
        alti_soft = position.y/0.1
    if position.y > MAX_ALTI-2.0 and %ascend.value > 0:
        alti_soft = -(position.y-MAX_ALTI)/2.0

    var fs = Vector2(%strafe.value, %forward.value).limit_length()

    var force = Vector3.ZERO
    force += player.transform.basis.x * fs.x * dt * moveSpeed
    force -= player.transform.basis.z * fs.y * dt * moveSpeed
    force += player.transform.basis.y * %ascend.value * dt * ascendSpeed# * alti_soft
    
    apply_central_force(force)
    apply_torque(Vector3(0, -%steer.value*dt/Engine.time_scale*steerSpeed, 0))
    
    #position.y = clamp(position.y, 0, MAX_ALTI)
    
    player.transform = transform

func _integrate_forces(state: PhysicsDirectBodyState3D):
    
    state.linear_velocity = state.linear_velocity.limit_length(maxSpeed)
    
func readInput():

    %ascend.zero()
    %ascend.add(Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT))
    %ascend.add(-Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT))
    
    if Input.is_action_pressed("alt_right"): %ascend.add( 1)
    if Input.is_action_pressed("alt_down"):  %ascend.add(-1)
    if Input.is_key_pressed(KEY_R): %ascend.add( 1)
    if Input.is_key_pressed(KEY_F): %ascend.add(-1)
    
    %forward.zero()
    %forward.add(-Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
    
    if Input.is_action_pressed("forward"):      %forward.add(1)
    if Input.is_action_pressed("backward"):     %forward.add(-1)
    if Input.is_key_pressed(KEY_UP):            %forward.add(1)
    if Input.is_key_pressed(KEY_DOWN):          %forward.add(-1)
    
    %strafe.zero()
    %strafe.add(Input.get_joy_axis(0, JOY_AXIS_LEFT_X))
    if Input.is_action_pressed("right"):        %strafe.add(1)
    if Input.is_action_pressed("left"):         %strafe.add(-1)

    %steer.zero()
    %steer.add(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X))
    if Input.is_action_pressed("steer_right"):  %steer.add(1)
    if Input.is_action_pressed("steer_left"):   %steer.add(-1)
