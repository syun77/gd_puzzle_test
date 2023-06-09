extends GridObject

# カギオブジェクト.
class_name Key

## セットアップ.
func setup(i:int, j:int) -> void:
	set_pos(i, j, false)
	
func vanish() -> void:
	var pos = Field.idx_to_world(_point, true)
	Common.start_particle(pos, 0.5, Color.YELLOW, 1.0)
	Common.start_particle_ring(pos, 0.8, Color.YELLOW, 4.0)
	queue_free()
	
## 更新
func proc(delta: float) -> void:
	pre_update()
	update_state()
	match _state:
		eState.STANDBY:
			_update_standby(delta)
		eState.MOVING:
			update_moving(delta)
		eState.CONVEYOR_BELT:
			update_conveyor_belt(delta)
	post_update()

## 更新 > 待機.
func _update_standby(delta:float) -> void:
	if carried:
		return # 運ばれているときはベルトコンベアで動かない.
	
	# 置かれている場合はレーザーの壁扱いとなる.
	Field.biton_block_map(_point.x, _point.y)
	
	if check_conveyor_belt():
		_timer = 0
		_state = eState.CONVEYOR_BELT

## 運ばれているかどうか.
var carried:bool = false:
	set(b):
		carried = b
	get:
		return carried
