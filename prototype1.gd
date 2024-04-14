extends Node

@export var skill_db: Array[SummonData] = []
@export var deck_count: int = 10
@export var hand_count: int = 3


var summoner: CharacterBody3D

var summon_gui: Control
var camera: Camera3D

var summons: Node3D
var cast_range: MeshInstance3D

var skill_deck: Array[SummonData] = []
var skill_hand: Array[SummonData] = []

var summoning: SummonData
var current_clicked: int
func _ready():
    summon_gui = get_node("%SummoningGUI")
    cast_range = get_node("%CastRange")
    camera = get_node("%Camera3D")
    summons = get_node("%Summons")
    summoner = get_node("Summoner")

    cast_range.hide()
    init_level()


func init_level():
    summoner.position = get_node("%StartPosition").position
    for i in range(deck_count):
        skill_deck.append(skill_db.pick_random())

    for i in range(hand_count):
        var new_skill: SummonData = skill_deck.pop_back()
        skill_hand.push_back(new_skill)

    summon_gui.update_hand(skill_hand)


func _on_cards_gui_card_clicked(p_which_skill: int):
    self.current_clicked = p_which_skill
    var summoning_skill = skill_hand[self.current_clicked]
    self.summoning = summoning_skill
    show_summon_area()


func refill_card():
    skill_hand.pop_at(self.current_clicked)
    if skill_deck.size() == 0:
        hand_count -= 1
    else:
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


func _process(_delta):
    if summoning:
        var current_position: Vector2 = get_viewport().get_mouse_position()
        var world_position: Vector3 = camera.project_position(current_position, camera.position.z)
        print(world_position)
        get_node("aa").position = world_position

        var summoning_radius: int = summoning.summoning_range

        var spawn_position = cast_range.global_position
        spawn_position.z -= 2.0
        var valid_position: bool = world_position.distance_to(spawn_position) <= summoning_radius
        if Input.is_action_just_pressed("confirm") and valid_position:
            cast_range.hide()
            do_summoning(world_position)
            refill_card()


func _on_goal_body_entered(body:Node3D):
    if body.name == "Summoner":
        print("You Win!")
        # get_tree().change_scene("res://scenes/Level.tscn")

