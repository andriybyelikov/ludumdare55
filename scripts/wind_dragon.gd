extends Node3D

@export var force_strength: float = 3000.0
# @export var impulse_frequency: float = 0.3
@export var max_distance: float = 3.0

var aoe: Area3D
# var down_time: float = 0.0
func _ready():
    aoe = get_node("Aoe")

func _physics_process(delta):
    # if down_time > 0:
    #     down_time -= delta
    #     return

    for body in aoe.get_overlapping_bodies():
        if body is Summoner:
            var distance: float = body.position.distance_to(self.position)
            var attenuation: float = clamp(distance/max_distance, 0.0, 1.0)
            # down_time = impulse_frequency
            var force_direction: Vector3  = Vector3.UP.rotated(Vector3.FORWARD, self.rotation.z)
            print(attenuation)
            body.force_accumulator += force_direction*force_strength
