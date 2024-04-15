extends Control

func _on_new_game_button_pressed():
    var game_scene = load("res://prototype1.tscn")
    var new_game = game_scene.instantiate()
    self.get_tree().get_root().add_child(new_game)
    self.queue_free()


func _on_credits_button_pressed():
    %AcceptDialog.visible = true
