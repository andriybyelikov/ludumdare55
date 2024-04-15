extends Node

@export var levels: Array[PackedScene] = []
@export var hand_count: int = 3

var title_scene = preload("res://tittle_screen.tscn")

var current_level: int = 0
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
    init_level(current_level)


func init_level(level_index: int):
    cancel_summoning()
    skill_hand.clear()
    skill_deck.clear()

    level = levels[level_index].instantiate()
    self.add_child(level)

    summons = level.get_node("%Summons")
    summoner.position = level.get_node("%StartPosition").position
    var goal = level.get_node("%Goal")
    skill_deck = level.skill_db.duplicate()

    for i in range(min(hand_count, skill_deck.size())):
        var new_skill: SummonData = skill_deck.pop_front()
        skill_hand.push_back(new_skill)

    summon_gui.update_hand(skill_hand)
    goal.body_entered.connect(_on_goal_body_entered)
    await get_tree().process_frame # Wait for player position to update to level start
    goal.monitoring = true


func _on_cards_gui_card_clicked(p_which_skill: int):
    self.current_clicked = p_which_skill
    var summoning_skill = skill_hand[self.current_clicked]
    self.summoning = summoning_skill
    show_summon_area()

func cancel_summoning():
    cast_range.hide()
    self.current_clicked = -1
    self.summoning = null

func try_refill_hand():
    skill_hand.pop_at(self.current_clicked)
    if skill_deck.size() > 0:
        var new_summon_skill: SummonData = skill_deck.pop_back()
        skill_hand.push_back(new_summon_skill)

    summon_gui.update_hand(skill_hand)
    cancel_summoning()


func show_summon_area():
    var distance: int = summoning.summoning_range
    cast_range.scale = distance*Vector3.ONE*2.0 # radius
    cast_range.show()


func do_summoning(p_position: Vector3):
    match summoning.name:
        "UFO":
            spawn_ufo(p_position)
        _:
            var summon_scene: Node = summoning.model.instantiate()
            summons.add_child(summon_scene)
            summon_scene.position = p_position


func spawn_ufo(p_position: Vector3):
    await summoner.play_ufo()
    summoner.position = p_position
    summoner.play_ufo(false)


func _click_terrain_collision(p_position: Vector3):
    raycast.global_position = camera.global_position
    raycast.global_position.z *= -1 # So that does not block view for debugging
    raycast.target_position = p_position-raycast.global_position
    return raycast.is_colliding()

func _player_terrain_collision(p_position: Vector3):
    raycast.global_position = summoner.global_position
    raycast.target_position = p_position-raycast.global_position
    return raycast.is_colliding()

func _valid_spawn_radius(p_position: Vector3):
    var spawn_position = cast_range.global_position
    var within_spawn_radius: bool = p_position.distance_to(spawn_position) <= summoning.summoning_range
    return within_spawn_radius


func _is_valid_summon_position(p_position: Vector3):
    if summoning.through_walls:
        return _valid_spawn_radius(p_position) and not _click_terrain_collision(p_position)
    return _valid_spawn_radius(p_position) and not _player_terrain_collision(p_position)
    # match summoning.name:
        # "UFO":
        #     return _valid_spawn_radius(p_position) and not _player_terrain_collision(p_position)
        # _:
        #     return _valid_spawn_radius(p_position) and not _click_terrain_collision(p_position)


func _unhandled_input(event):
    if event is InputEventMouseButton:
        if Input.is_action_just_pressed("confirm"):
            var mouse_position: Vector2 = get_viewport().get_mouse_position()
            var mouse_world_position = camera.project_position(mouse_position, camera.position.z)
            if summoning and _is_valid_summon_position(mouse_world_position):
                do_summoning(mouse_world_position)
                try_refill_hand()
        elif Input.is_action_just_pressed("cancel"):
            cancel_summoning()
    if event is InputEventKey:
        if Input.is_action_just_pressed("reset_level"):
            _reset_level()


func _process(_delta):
    var current_position: Vector2 = get_viewport().get_mouse_position()
    var mouse_world_position = camera.project_position(current_position, camera.position.z)
    get_node("mouse").position = mouse_world_position
    if summoning:
        var material = cast_range.mesh.surface_get_material(0)
        if _is_valid_summon_position(mouse_world_position):
            material.albedo_color = Color(1, 1, 1, 1.0)
        else:
            material.albedo_color = Color(0, 0, 0, 1.0)

func _reset_level():
    level.queue_free()
    init_level(current_level)

func _on_goal_body_entered(body:Node3D):
    if body.name == "Summoner":
        current_level = current_level + 1
        if current_level >= levels.size():
            var title = title_scene.instantiate()
            self.get_tree().get_root().add_child(title)
            self.queue_free()
        else:
            _reset_level()

func _on_level_reset_button_pressed():
    _reset_level()

