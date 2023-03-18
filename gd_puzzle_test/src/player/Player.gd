extends GridObject

# ===========================
# プレイヤー.
# ===========================

class_name Player
# ---------------------------------------
# consts.
# ---------------------------------------

# ---------------------------------------
# preload.
# ---------------------------------------
const EFFECT_LOCK_OBJ = preload("res://src/effect/EffectLock.tscn")

# ---------------------------------------
# onready.
# ---------------------------------------
@onready var _spr = $Sprite

# ---------------------------------------
# vars.
# ---------------------------------------
var _anim_timer = 0
var _key:Key = null
var _timer2 = 0.0

# ---------------------------------------
# public functions.
# ---------------------------------------
func vanish() -> void:
	var pos = Field.idx_to_world(_point, true)
	Common.start_particle(pos, 1.0, Color.MAGENTA, 2.0)
	Common.start_particle_ring(pos, 1.0, Color.MAGENTA, 8.0)
	
	queue_free()

func proc(delta:float) -> void:
	if request_kill:
		modulate = Color.RED
		_timer2 += delta
		var t = 0.5 - _timer2
		if t > 0:
			var v = t * 4
			_spr.offset.x = randf_range(-v, v)
			_spr.offset.y = randf_range(-v, v)
		visible = int(_timer2*20)%2 == 0
		return # 操作できない.
	
	_anim_timer += delta

	match _state:
		eState.STANDBY:
			_update_standby(delta)
		eState.MOVING:
			update_moving(delta)
		eState.CONVEYOR_BELT:
			update_conveyor_belt(delta)
		
	_spr.frame = _get_anim_id(int(_anim_timer*4)%2)
	
	# カギ持っている場合の更新.
	_update_key()

	
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
			return
	
	if Input.is_action_just_pressed("ui_accept"):
		# 決定ボタン.
		if is_instance_valid(_key):
			# 鍵を持っていたら地面に置く.
			_put_key()


## カギを持っているときの更新
func _update_key() -> void:
	if is_instance_valid(_key) == false:
		return # 持っていない.
	
	if _state == eState.STANDBY:
		# カギの使用チェック.
		if _check_use_key():
			return
		
	var pos = Vector2(_point.x, _point.y)
	pos += Direction.to_vector(_dir) * 0.5
	_key.set_pos(pos.x, pos.y, false)

## カギを使うチェック
func _check_use_key() -> bool:
	var forward = forward_pos()
	var v = Field.get_cell(forward.x, forward.y)
	if v == Field.eTile.LOCK:
		# 目の前がロックなのでカギを使う.
		Field.erase_cell(forward.x, forward.y)
		var effect = EFFECT_LOCK_OBJ.instantiate()
		Common.get_layer("effect").add_child(effect)
		effect.setup(forward)
		_key.vanish()
		_key = null
		return true
	# 使わない.
	return false


## カギを置く.
func _put_key() -> void:
	var pos = forward_pos()
	if Field.can_move(pos.x, pos.y):
		# 移動可能なので置ける.
		_key.carried = false
		_key.set_pos(pos.x, pos.y, false)
		_key = null

## 移動.
func _check_move() -> bool:
	# 移動先を調べる.
	var prev_dir = _dir # 移動前の向き
	var now = Vector2i(_point.x, _point.y)
	var next = Vector2i(_point.x, _point.y)
	# 移動方向.
	var d = Direction.to_vectori(_dir)
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

# ---------------------------------------
# properties.
# ---------------------------------------
## 死亡リクエスト
var request_kill:bool = false:
	set(b):
		request_kill = b
	get:
		return request_kill

# ---------------------------------------
# signal functions.
# ---------------------------------------
func _on_area_entered(area):
	if area is Key:
		# カギGet.
		_key = area
		_key.carried = true # 運んでいる.
	if area is Spike:
		request_kill = true
