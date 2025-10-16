class_name Heli
extends RigidBody3D
  
var speed        = 10.0
var maxSpeed     = 10.0
var ascendSpeed  = 15000
var steerSpeed   = 1000
var moveSpeed    = 30000
var maxVelocity  = 20.0

var MAX_ALTI     = 10.0
var contactCount = 0
var dashPower    = 200
var dash         = 0

@onready var collector: Node3D = %Collector

var player : Player :
    set(p) : player = p; global_position = p.global_position

func _ready():
    
    name = "Heli"
    applyCards()
    Post.subscribe(self)

func gamePaused(): stopLoops()    
func _exit_tree(): stopLoops()    
    
func stopLoops():
    
    Post.gameLoop.emit(self, "drive", 0, 0)
    Post.gameLoop.emit(self, "fly", 0, 0)
    
func applyCards():
    
    var cards = get_node("/root/World").currentLevel.cards
    var rangeCards = cards.permLvl(Card.PillRange)
    var powerCards = cards.permLvl(Card.PillPower)
    
    %LaserPointer.laserRange  = 3 + 2 * rangeCards
    %LaserPointer.laserDamage = pow(powerCards+1, 3)
    %LaserPointer.radiusBase = 0.04 + powerCards * 0.04
    
    dashPower = 170 + 30 * pow(powerCards+1, 1.5)
    
    %Collector.setRadius(7 + 7 * rangeCards)

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
    force.y = 0.0
    force += player.transform.basis.y * %ascend.value * dt * ascendSpeed * alti_soft

    apply_central_force(force)
    apply_torque(Vector3(0, -%steer.value*dt/Engine.time_scale*steerSpeed, 0))
    
    global_position.y = clamp(global_position.y, 0, MAX_ALTI)
    
    var volume = clampf(linear_velocity.length() / maxVelocity, 0.0, 1.0)
    if global_position.y < 0.05: 
        Post.gameLoop.emit(self, "drive", volume, 1.0 + volume)
        Post.gameLoop.emit(self, "fly", 0, 0)
    else:
        Post.gameLoop.emit(self, "fly", volume, 0.25 + volume * 0.75)
        Post.gameLoop.emit(self, "drive", 0, 0)

    player.transform = transform
    
func _integrate_forces(state: PhysicsDirectBodyState3D):
    
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
            dashDir.y = 0.0
            apply_central_impulse(dashDir * dashPower * %DashTimer.time_left/%DashTimer.wait_time)
    
func readInput():

    dash = 0
    if Input.is_action_pressed("dash"): dash = 1

    %forward.zero()
    %ascend.zero()
    %steer.zero()

    var triggerLeft = Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT)
    if triggerLeft > 0.1:
        if global_position.y > 0.1:
            %ascend.add(-triggerLeft)
        else:
            %forward.add(-triggerLeft)
    
    if Input.is_action_pressed("alt_down"):  %ascend.add(1)
    if Input.is_key_pressed(KEY_R):    %ascend.add( 1)
    if Input.is_key_pressed(KEY_F):    %ascend.add(-1)
    if Input.is_key_pressed(KEY_UP):   %ascend.add(1)
    if Input.is_key_pressed(KEY_DOWN): %ascend.add(-1)
    
    %forward.add( Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT))

    var steerForward = Input.get_vector("steer_left", "steer_right", "backward", "forward")
    %forward.add(steerForward.y)    
    %steer.add(steerForward.x)

    if Input.is_action_pressed("right"):        %steer.add(0.4)
    if Input.is_action_pressed("left"):         %steer.add(-0.4)
