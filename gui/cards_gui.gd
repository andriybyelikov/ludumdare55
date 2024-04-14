extends Control
signal no_cards
signal card_clicked(p_which_skill)

@export var skill_button: PackedScene
var hand: Control
func _ready():
    hand = get_node("%Hand")

func update_hand(p_current_hand: Array[SummonData]):
    var nodes = hand.get_children()
    for node in nodes:
        node.queue_free()

    for i in range(p_current_hand.size()):
        var card_data: SummonData = p_current_hand[i]
        var new_skill_button: Control = skill_button.instantiate()
        hand.add_child(new_skill_button)
        new_skill_button.set_skill(card_data)
        new_skill_button.skill_selected.connect(on_card_clicked.bind(i))


func on_card_clicked(p_which_skill: int):
    card_clicked.emit(p_which_skill)
