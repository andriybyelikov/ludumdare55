class_name SkillButton
extends Control

signal skill_selected()

var skill_button: TextureButton
var skill_label: Label
func _ready():
    skill_button = get_node("%SkillButton")
    skill_label = get_node("%SkillLabel")

    skill_button.pressed.connect(skill_pressed)

func skill_pressed():
    skill_selected.emit()

func set_skill(p_summon_data: SummonData):
    skill_button.texture_normal = p_summon_data.icon
    skill_label.text = p_summon_data.name

