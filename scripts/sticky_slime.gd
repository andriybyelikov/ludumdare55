extends Node3D
var aoe: Area3D
func _ready():
    aoe = get_node("Aoe")
    aoe.body_entered.connect(_stick)
    aoe.body_exited.connect(_unstick)

func _stick(body: Node3D):
    if body is Summoner:
        body.stuck = true
    elif body is WindDragon:
        print("Wind Dragon")
        body.freeze = true

func _unstick(body: Node3D):
    if body is Summoner:
        body.stuck = false
