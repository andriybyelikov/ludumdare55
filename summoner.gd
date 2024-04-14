extends CharacterBody3D

@export var speed: int = 10
@export var fall_acceleration: int = 75
@export var jump_impulse: int = 20

var target_velocity: Vector3 = Vector3.ZERO


func _physics_process(delta):
    var l: int = Input.is_action_pressed("move_left")
    var r: int = Input.is_action_pressed("move_right")
    var direction: Vector3 = Vector3(r - l, 0, 0)
    target_velocity.x = direction.x * speed
    target_velocity.z = direction.z * speed

    # falling
    if not is_on_floor():
        target_velocity.y -= fall_acceleration * delta

    # jumping
    if is_on_floor() and Input.is_action_just_pressed("jump"):
        print("jumping")
        target_velocity.y = jump_impulse

    velocity = target_velocity
    move_and_slide()

