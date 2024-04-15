class_name Summoner
extends CharacterBody3D

@export var speed: int = 10
@export var stuck_speed: int = 10
@export var fall_acceleration: int = 75
@export var jump_impulse: int = 20
@export var mass: float = 1.0

var force_accumulator: Vector3 = Vector3.ZERO

var target_velocity: Vector3 = Vector3.ZERO
var fixed_z: float = 0
var stuck: bool = false
func _ready():
    fixed_z = self.position.z

func _stuck_movement(delta: float):
    var l: int = Input.is_action_pressed("move_left")
    var r: int = Input.is_action_pressed("move_right")
    var u: int = Input.is_action_pressed("move_up")
    var d: int = Input.is_action_pressed("move_down")

    var direction: Vector3 = Vector3(r - l, u - d, 0)
    target_velocity = direction*stuck_speed

    if direction.x == 0 and direction.y == 0:
        $AnimationPlayer.set_current_animation("idle")
    else:
        $AnimationPlayer.set_current_animation("walk")

    # facing
    if direction.x < 0:
        $Pivot.rotation.y = - PI / 6
    elif direction.x > 0:
        $Pivot.rotation.y = + PI / 6
    # if Input.is_action_just_pressed("jump"):
    #     target_velocity.y = jump_impulse
    #     stuck = false

    var impulse: Vector3 = (force_accumulator / mass) * delta
    target_velocity += impulse
    velocity = target_velocity

func _normal_movement(delta: float):
    var l: int = Input.is_action_pressed("move_left")
    var r: int = Input.is_action_pressed("move_right")
    var direction: Vector3 = Vector3(r - l, 0, 0)
    target_velocity.x = direction.x * speed
    target_velocity.z = direction.z * speed
    if is_on_floor():
        if direction.x == 0 and direction.y == 0:
            $AnimationPlayer.set_current_animation("idle")
        else:
            $AnimationPlayer.set_current_animation("walk")

    # facing
    if direction.x < 0:
        $Pivot.rotation.y = - PI / 6
    elif direction.x > 0:
        $Pivot.rotation.y = + PI / 6

    # falling
    if is_on_ceiling():
        target_velocity.y = 0
    elif not is_on_floor():
        target_velocity.y -= fall_acceleration * delta
    # jumping
    elif is_on_floor() and Input.is_action_just_pressed("jump"):
        # print("jumping")
        target_velocity.y = jump_impulse

    var impulse: Vector3 = (force_accumulator / mass) * delta
    target_velocity += impulse
    velocity = target_velocity

func _physics_process(delta):
    self.position.z = fixed_z

    if stuck:
        _stuck_movement(delta)
    else:
        _normal_movement(delta)

    move_and_slide()
    force_accumulator = Vector3.ZERO
