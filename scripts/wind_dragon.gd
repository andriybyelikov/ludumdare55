extends Node3D

@export var force_strength: float = 300.0
# @export var impulse_frequency: float = 0.3
@export var max_distance: float = 10.0

var aoe: Area3D

func _ready():
    aoe = get_node("Aoe")
    var cylinder_shape: CylinderShape3D = $Aoe/CollisionShape3D.shape
    cylinder_shape.height = max_distance
    $Aoe/CollisionShape3D.position.y = max_distance / 2

func _physics_process(delta):

    for body in aoe.get_overlapping_bodies():
        if body is Summoner:
            var force_direction: Vector3  = Vector3.UP.rotated(Vector3.FORWARD, self.rotation.z).normalized()
            
            # TODO this logic is only for close to UP levitating: example: if dot_product(UP, force_direction) > 0.9
            if body.position.y - position.y > max_distance:
                body.position.y = position.y + max_distance
                var animation_player: AnimationPlayer = body.get_node("AnimationPlayer")
                animation_player.set_current_animation("levitate")
            else:
                body.force_accumulator += force_direction*force_strength
                
