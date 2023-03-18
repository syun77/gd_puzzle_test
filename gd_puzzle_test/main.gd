extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_size(Vector2i(1152*2, 648*2))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
