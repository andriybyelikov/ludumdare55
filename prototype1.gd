extends Node

@export var levels: Array[PackedScene] = []

@export var deck_count: int = 3
@export var hand_count: int = 3
var current_level: int = -1
var level: Node3D

var summoner: CharacterBody3D

var summon_gui: Control
var camera: Camera3D

var summons: Node3D
var cast_range: MeshInstance3D

var skill_deck: Array[SummonData] = []
var skill_hand: Array[SummonData] = []

var summoning: SummonData
var current_clicked: int
var raycast: RayCast3D
func _ready():
    summon_gui = get_node("%SummoningGUI")
    cast_range = get_node("%CastRange")
    camera = get_node("%Camera3D")
    summoner = get_node("Summoner")
    raycast = get_node("%RayCast3D")

    cast_range.hide()
    init_level()


func init_level():
    skill_hand.clear()
    skill_deck.clear()

    current_level = (current_level + 1) % levels.size()
    level = levels[current_level].instantiate()
    self.add_child(level)

    summons = level.get_node("%Summons")
    summoner.position = level.get_node("%StartPosition").position
    var goal = level.get_node("%Goal")
    goal.body_entered.connect(_on_goal_body_entered)

    for i in range(deck_count):
        skill_deck.append(level.skill_db.pick_random())

    for i in range(hand_count):
        var new_skill: SummonData = skill_deck.pop_back()
        skill_hand.push_back(new_skill)

    summon_gui.update_hand(skill_hand)


func _on_cards_gui_card_clicked(p_which_skill: int):
    self.current_clicked = p_which_skill
    var summoning_skill = skill_hand[self.current_clicked]
    self.summoning = summoning_skill
    show_summon_area()


func try_refill_hand():
    skill_hand.pop_at(self.current_clicked)
    if skill_deck.size() > 0:
        var new_summon_skill: SummonData = skill_deck.pop_back()
        skill_hand.push_back(new_summon_skill)

    summon_gui.update_hand(skill_hand)
    self.current_clicked = -1
    self.summoning = null


func show_summon_area():
    var distance: int = summoning.summoning_range
    cast_range.scale = distance*Vector3.ONE*2.0 # radius
    cast_range.show()


func do_summoning(p_position: Vector3):
    var summon_scene: Node = summoning.model.instantiate()
    match summoning.name:
        "UFO":
            spawn_ufo(p_position)
        _:
            summons.add_child(summon_scene)
            summon_scene.position = p_position


func spawn_ufo(p_position: Vector3):
    summoner.position = p_position

func _click_terrain_collision(p_position: Vector3):
    raycast.global_position = camera.global_position
    # raycast.global_position.z *= -1 // So that does not block view for debugging
    raycast.target_position = p_position-raycast.global_position
    return raycast.is_colliding()

func _player_terrain_collision(p_position: Vector3):
    raycast.global_position = summoner.global_position
    raycast.target_position = p_position-raycast.global_position
    return raycast.is_colliding()


func _is_valid_summon_position(p_position: Vector3):
    var summoning_radius: int = summoning.summoning_range
    var spawn_position = cast_range.global_position
    var within_spawn_radius: bool = p_position.distance_to(spawn_position) <= summoning_radius
    return within_spawn_radius and not _click_terrain_collision(p_position)


func _unhandled_input(event):
    if event is InputEventMouseButton and summoning:
        var mouse_position: Vector2 = get_viewport().get_mouse_position()
        var mouse_world_position = camera.project_position(mouse_position, camera.position.z)

        if Input.is_action_just_pressed("confirm") and _is_valid_summon_position(mouse_world_position):
            cast_range.hide()
            do_summoning(mouse_world_position)
            try_refill_hand()


func _process(_delta):
    if summoning:
        var current_position: Vector2 = get_viewport().get_mouse_position()
        var world_position = camera.project_position(current_position, camera.position.z)
        get_node("aa").position = world_position
        var material = cast_range.mesh.surface_get_material(0)
        if _is_valid_summon_position(world_position):
            material.albedo_color = Color(1, 1, 1, 1.0)
        else:
            material.albedo_color = Color(0, 0, 0, 1.0)



func _on_goal_body_entered(body:Node3D):
    if body.name == "Summoner":
        print("You Win!")
        level.queue_free()
        init_level()
        # get_tree().change_scene("res://scenes/Level.tscn")

