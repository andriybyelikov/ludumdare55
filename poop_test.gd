extends Node2D


var array = [1, 2, 3 ,4 ,5]
# Called when the node enters the scene tree for the first time.
func _ready():
    print(array.size())
    array.pop_at(2)
    print(array.size())
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
