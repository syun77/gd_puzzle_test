extends GridObject

class_name Spike

@onready var _spr = $Sprite2D

var _anim_timer = 0.0

func setup(i:int, j:int) -> void:
	set_pos(i, j, false)

func vanish() -> void:
	var pos = Field.idx_to_world(_point, true)
	Common.start_particle(pos, 0.5, Color.BROWN, 2.0)
	queue_free()

func proc(delta:float) -> void:
	_anim_timer += delta
	_spr.frame = int(_anim_timer * 8)%4

func _on_area_entered(area):
	if area is Crate:
		vanish()
