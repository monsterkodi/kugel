class_name Pill 
extends RigidBody3D

var player: Node3D
var speed = 6
var steerSpeed = 150
var dash  = 0

var mouseRot     = 0.0
var mouseDelta   = Vector2.ZERO
var dashDir      = Vector3.FORWARD
var dashPower    = 200
var jumpDir      = 1
var jumpPower    = 100
var contactCount = 0

var maxVelocity  = 20.0

@onready var collector: Node3D = %Collector

func _ready():
    
    name = "Pill"
    #global_position = Vector3.UP
    applyCards()
    Post.subscribe(self)
    
func gamePaused(): stopLoops()
func _exit_tree(): stopLoops()

func stopLoops():
    
    Post.gameLoop.emit(self, "move", 0, 0)
    
func applyCards():
    
    var rangeCards = Info.permLvl(Card.PillRange)
    var powerCards = Info.permLvl(Card.PillPower)
    
    %LaserPointer.laserRange  = 3 + 2 * rangeCards
    %LaserPointer.laserDamage = pow(powerCards+1, 3)
    %LaserPointer.radiusBase = 0.04 + powerCards * 0.04
    
    dashPower = 170 + 30 * pow(powerCards+1, 1.5)
    jumpPower = 80 + 20 * pow(powerCards+1, 1.5)
    
    %Collector.setRadius(7 + 7 * rangeCards)
    
func _physics_process(delta:float):
    
    if not player: return
    
    var dt = delta * speed / Engine.time_scale
    
    readInput()

    var fs = Vector2(%strafe.value, %forward.value).limit_length()
        
    var force = Vector3.ZERO
    force += player.transform.basis.x * fs.x * dt * 1000
    force -= player.transform.basis.z * fs.y * dt * 1000
    
    apply_central_force(force)
    apply_torque(Vector3(0, -%steer.value*dt/Engine.time_scale*steerSpeed, 0))
        
    apply_torque(Vector3(0, -mouseDelta.x*dt*1.5, 0))
    mouseDelta = Vector2.ZERO

    calcDashDir(dt)
     
    %LaserPointer.setDir(dashDir)
    
    var moveVolume = clampf(linear_velocity.length() / maxVelocity, 0.0, 1.0)
    #Post.gameLoop.emit(self, "move", moveVolume / 8.0, moveVolume*2.0)
    Post.gameLoop.emit(self, "move", maxf(0.0, 0.05 - global_position.y), moveVolume)

    player.transform = transform
    
func _integrate_forces(state: PhysicsDirectBodyState3D):
   
    var newContactCount = get_contact_count() 
    
    var doJump = Input.is_action_just_pressed("jump")
    
    if contactCount == 0 and newContactCount == 1:
        Post.gameSound.emit(self, "land", state.get_contact_impulse(0).length())
        doJump = Input.is_action_pressed("jump")
        %JumpBlock.stop()
    
    contactCount = newContactCount
    
    if contactCount > 1:
        Post.gameSound.emit(self, "hit", state.get_contact_impulse(1).length())
    
    state.linear_velocity = state.linear_velocity.limit_length(speed)
    
    if doJump and %JumpBlock.is_stopped():
        var jumpSound
        if contactCount > 0:
            jumpDir = 1
            jumpSound = "jump"
        else:
            jumpDir = -1
            jumpSound = "drop"
        
        if jumpDir > 0 or global_position.y > 0.1:    
            %JumpTimer.start()
            %JumpBlock.start()
            Post.gameSound.emit(self, jumpSound)
            
    if not %JumpTimer.is_stopped():
        var jumpImpulse 
        if jumpDir > 0:
            jumpImpulse = Vector3.UP * jumpPower * %JumpTimer.time_left/%JumpTimer.wait_time
        else: 
            jumpImpulse = -global_position.y * Vector3.UP * jumpPower * (1.0 - %JumpTimer.time_left/%JumpTimer.wait_time)
        apply_central_impulse(jumpImpulse)
                    
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
            apply_central_impulse(dashDir * dashPower * %DashTimer.time_left/%DashTimer.wait_time)

func calcDashDir(delta:float):
    
    var dt  = delta
    var dir = Vector3.ZERO
    
    if mouseDelta.x != 0: 
        mouseRot += mouseDelta.x*0.0005
        mouseRot = clampf(mouseRot,-PI, PI)
    mouseRot = lerpf(mouseRot, 0.0, dt)

    var move = Input.get_vector("left", "right", "forward", "backward")
    
    if move.x or move.y:
        dir += move.x * global_transform.basis.x
        dir += move.y * global_transform.basis.z
        dir = dir.normalized()
    else:
        dir = -global_basis.z
    
    if Input.is_key_pressed(KEY_LEFT):   mouseRot -= dt
    if Input.is_key_pressed(KEY_RIGHT):  mouseRot += dt
    
    mouseRot += Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) * dt * 0.5
    
    if mouseRot:
        dir = dir.rotated(Vector3.UP, -mouseRot)
    
    dashDir = lerp(dashDir, dir, dt*0.2)  
    
func readInput():
    
    %forward.zero()
    %forward.add(-Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))

    dash = Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT)
    #if Input.is_action_just_pressed("dash"):    dash = 1
    if Input.is_action_pressed("dash"):    dash = 1
    
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
    if Input.is_action_pressed("right"):        %strafe.add( 1)
    if Input.is_action_pressed("left"):         %strafe.add(-1)

func _input(event: InputEvent):
    
    if event is InputEventMouseMotion:
        mouseDelta = event.relative
