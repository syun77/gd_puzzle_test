extends GridObject

# ===========================
# プレイヤー.
# ===========================

class_name Player
# ---------------------------------------
# preload.
# ---------------------------------------

# ---------------------------------------
# onready.
# ---------------------------------------
@onready var _spr = $Sprite

# ---------------------------------------
# vars.
# ---------------------------------------
var _anim_timer = 0

# ---------------------------------------
# public functions.
# ---------------------------------------
func proc(delta:float) -> void:
	_anim_timer += delta

	# キーの入力判定.
	var is_moving = false
	if Input.is_action_just_pressed("ui_left"):
		_dir = Direction.eType.LEFT
		is_moving = true
	elif Input.is_action_just_pressed("ui_up"):
		_dir = Direction.eType.UP
		is_moving = true
	elif Input.is_action_just_pressed("ui_right"):
		_dir = Direction.eType.RIGHT
		is_moving = true
	elif Input.is_action_just_pressed("ui_down"):
		_dir = Direction.eType.DOWN		
		is_moving = true
	
	if is_moving:
		# 移動する.
		_move()
		
	_spr.frame = _get_anim_id(int(_anim_timer*4)%2)
	
# ---------------------------------------
# private functions.
# ---------------------------------------
func _ready() -> void:
	pass

## 移動.
func _move() -> void:
	# 移動先を調べる.
	var prev_dir = _dir # 移動前の向き
	var now = Vector2i(_point.x, _point.y)
	var next = Vector2i(_point.x, _point.y)
	# 移動方向.
	var d = Direction.to_vector(_dir)
	next += d
	
	if Field.is_crate(next.x, next.y):
		# 移動先が荷物.
		if Field.can_move_crate(next.x, next.y, d.x, d.y):
			# 移動できる.
			# 荷物を動かす.
			Field.move_crate(next.x, next.y, d.x, d.y)
			# プレイヤーも動かす.
			set_pos(next.x, next.y, false)
		
	elif Field.can_move(next.x, next.y):
		# 移動可能.
		set_pos(next.x, next.y, false)

## アニメーションIDを取得する.
func _get_anim_id(idx:int) -> int:
	var tbl = [0, 1]

	match _dir:
		Direction.eType.LEFT:
			tbl = [0, 1]
		Direction.eType.UP:
			tbl = [4, 5]
		Direction.eType.RIGHT:
			tbl = [8, 9]
		_: #Direction.eType.DOWN:
			tbl = [12, 13]
			
	return tbl[idx]
