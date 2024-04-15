class_name WindDragon
extends Node3D

@export var force_strength: float = 2000.0
@export var max_distance: float = 15.0

var aoe: Area3D
var cylinder_shape: CylinderShape3D  # NOTE: Dynamic shape for testing or future effects

func _ready():
	cylinder_shape = $Aoe/CollisionShape3D.shape
	aoe = get_node("Aoe")


func _physics_process(_delta):
	cylinder_shape.height = max_distance
	$Aoe/CollisionShape3D.position.y = max_distance / 2 + 1.0  # 2 is margin
	for body in aoe.get_overlapping_bodies():
		if body is Summoner:
			var force_direction: Vector3 = (
				Vector3.UP.rotated(Vector3.FORWARD, -self.rotation.z).normalized()
			)
			# TODO: this logic is only for close to UP levitating: example: if dot_product(UP, force_direction) > 0.9
			var attenuation: float = (
				1.0 - clamp(body.position.distance_to(position) / max_distance, 0.0, 1.0)
			)
			body.force_accumulator += force_direction * force_strength * attenuation
			var animation_player: AnimationPlayer = body.get_node("AnimationPlayer")
			animation_player.set_current_animation("levitate")
