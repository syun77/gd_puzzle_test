extends GridObject

# ===========================
# プレイヤー.
# ===========================

class_name Player
# ---------------------------------------
# consts.
# ---------------------------------------
enum eState {
	STANDBY,
	MOVING,
}

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
var _state := eState.STANDBY
var _timer = 0.0
var _anim_timer = 0

# ---------------------------------------
# public functions.
# ---------------------------------------
func proc(delta:float) -> void:
	_anim_timer += delta

	match _state:
		eState.STANDBY:
			_update_standby(delta)
		eState.MOVING:
			_update_moving(delta)
		
	_spr.frame = _get_anim_id(int(_anim_timer*4)%2)
	
# ---------------------------------------
# private functions.
# ---------------------------------------
func _ready() -> void:
	pass

## 更新 > 停止中.
func _update_standby(delta:float) -> void:
	# キーの入力判定.
	var is_moving = false
	if Input.is_action_pressed("ui_left"):
		_dir = Direction.eType.LEFT
		is_moving = true
	elif Input.is_action_pressed("ui_up"):
		_dir = Direction.eType.UP
		is_moving = true
	elif Input.is_action_pressed("ui_right"):
		_dir = Direction.eType.RIGHT
		is_moving = true
	elif Input.is_action_pressed("ui_down"):
		_dir = Direction.eType.DOWN		
		is_moving = true
	
	if is_moving:
		# 移動する.
		if _check_move():
			_timer = 0
			_state = eState.MOVING

## 更新 > 移動中.
func _update_moving(delta:float) -> void:
	_timer = update_move(_timer, delta)
	if _timer >= 1:
		set_pos(_next_pos.x, _next_pos.y, false)
		_state = eState.STANDBY
	else:
		set_pos(_point.x, _point.y, false)		

## 移動.
func _check_move() -> bool:
	# 移動先を調べる.
	var prev_dir = _dir # 移動前の向き
	var now = Vector2i(_point.x, _point.y)
	var next = Vector2i(_point.x, _point.y)
	# 移動方向.
	var d = Direction.to_vector(_dir)
	next += d
	
	var can_move = false
	
	if Field.is_crate(next.x, next.y):
		# 移動先が荷物.
		if Field.can_move_crate(next.x, next.y, d.x, d.y):
			# 移動できる.
			# 荷物を動かす.
			Field.move_crate(next.x, next.y, d.x, d.y)
			# プレイヤーも動かす.
			can_move = true
		
	elif Field.can_move(next.x, next.y):
		# 移動可能.
		can_move = true
	
	if can_move:
		# 移動先覚えておく.
		_prev_pos = now
		_next_pos = next
	return can_move

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
