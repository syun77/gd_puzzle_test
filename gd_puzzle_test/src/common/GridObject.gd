extends Area2D

# ===========================
# グリッド(インデックス)座標系で動作するオブジェクトの既定.
# ===========================
class_name GridObject
	

# ---------------------------------------
# consts.
# --------------------------------------
enum eState {
	STANDBY, # 待機中.
	MOVING, # 移動中.
	CONVEYOR_BELT, # ベルトコンベアで移動中.
}

enum eMove {
	DEFALUT,
	LINEAR,
}

func is_moving(state:eState) -> bool:
	var tbl = [
		eState.MOVING, # 移動中.
		eState.CONVEYOR_BELT, # ベルトコンベアで移動中.
	]
	return state in tbl
# ---------------------------------------
# class.
# ---------------------------------------
class StateObject:
	var now:eState
	var prev:eState
	var next:eState
	var changed:bool = false
	var cnt:int = 0
	func _init() -> void:
		now = eState.STANDBY
		prev = now
		next = now
		cnt = 0
		changed = false
	func change(v:eState) -> void:
		next = v
		changed = true
	func is_first() -> bool:
		return cnt == 0
	func update() -> void:
		if changed:
			prev = now
			now = next
			cnt = 0
			changed = false
		else:
			cnt += 1

# ---------------------------------------
# vars.
# ---------------------------------------
var _point = Vector2.ZERO
var _dir:int = Direction.eType.DOWN
var _prev_pos = Vector2i.ZERO
var _next_pos = Vector2i.ZERO
var _timer = 0.0
var _state_obj = StateObject.new()


## 状態
var _state := eState.STANDBY:
	set(v):
		_state_obj.change(v)
	get:
		return _state_obj.now

# ---------------------------------------
# public functions.
# ---------------------------------------
## グリッド座標系を設定.	
func set_pos(i:float, j:float, is_center:bool) -> void:
  # グリッド座標系をワールド座標に変換して描画座標に反映する.
	position.x = Field.idx_to_world_x(i, is_center)
	position.y = Field.idx_to_world_y(j, is_center)

	# グリッド座標を設定.
	_point.x = i
	_point.y = j

## 方向を設定する.
func set_dir(dir:int) -> void:
	_dir = dir

## 前方の座標を取得する.
func forward_pos() -> Vector2:
	return _point + Direction.to_vector(_dir)

## 指定の座標と一致しているかどうか.
func is_same_pos(i:int, j:int) -> bool:
	if is_moving(_state):
		# 移動中の場合は移動後で判定する.
		return _next_pos.x == i and _next_pos.y == j
	return _point.x == i and _point.y == j

## グリッド座標系のXを取得する.
func idx_x() -> int:
	return _point.x

## グリッド座標系のYを取得する.
func idx_y() -> int:
	return _point.y


## 更新 > 移動中.
func update_moving(delta:float) -> void:
	_timer = update_move(_timer, delta)
	if _timer >= 1:
		set_pos(_next_pos.x, _next_pos.y, false)
		if check_conveyor_belt():
			# ベルトコンベアを踏んだ.
			_timer = 0
			_state = eState.CONVEYOR_BELT
		else:
			_state = eState.STANDBY
	else:
		set_pos(_point.x, _point.y, false)

## 更新 > ベルトコンベア.
func update_conveyor_belt(delta:float) -> void:
	_timer = update_move(_timer, delta, eMove.LINEAR)
	if _timer >= 1:
		set_pos(_next_pos.x, _next_pos.y, false)
		if check_conveyor_belt():
			# ベルトコンベアを踏んだ.
			_timer = 0
			change_state(eState.CONVEYOR_BELT)
		else:
			_state = eState.STANDBY
	else:
		set_pos(_point.x, _point.y, false)

## 共通移動処理.
func update_move(t:float, delta:float, type:eMove=eMove.DEFALUT) -> float:
	match type:
		eMove.LINEAR:
			t += delta * 7
			_point = lerp(Vector2(_prev_pos), Vector2(_next_pos), t)
		_:
			t += delta * 7
			_point = lerp(Vector2(_prev_pos), Vector2(_next_pos), Ease.cube_out(t))
	
	return t

## ベルトコンベアを踏んだかどうかチェックする
func check_conveyor_belt() -> bool:
	var v = Field.get_cell(_point.x, _point.y)
	if Field.is_conveyor_belt(v) == false:
		return false # ベルトコンベアでない.
	
	var dir = Field.conveyor_belt_to_dir(v)
	var next = _point + Direction.to_vector(dir)
	if Field.can_move(next.x, next.y) == false:
		return false # 移動できない場合はベルトコンベア無効.
	
	_prev_pos = _point
	_next_pos = next
	return true

## 前処理.
func pre_update() -> void:
	pass
	
## 後処理.
func post_update() -> void:
	# 移動後処理.
	if is_change() == false:
		return # eStateの変化なし.
		
	if is_stomp_pit():
		# ピットを踏んだ.
		if has_method("cb_stomp_pit"):
			call("cb_stomp_pit")
	
	# スイッチの処理.
	var px = _point.x
	var py = _point.y
	var v = Field.get_cell(px, py)
	if Field.switch_check(px, py) == false:
		# ONにする
		Field.switch_on(px, py)
	if is_moving(_state_obj.prev):
		# 移動処理完了.
		Field.switch_off(_prev_pos.x, _prev_pos.y)

## ピットを踏んだかどうか.
func is_stomp_pit() -> bool:
	var v = Field.get_cell(_point.x, _point.y)
	if v in [Field.eTile.PIT_ON, Field.eTile.PIT2_ON]:
		return true # ピットを踏んだ.
	return false

## stateの更新.
func update_state() -> void:
	_state_obj.update()
func is_first() -> bool:
	return _state_obj.is_first()
func is_change() -> bool:
	return _state_obj.changed
func change_state(v:eState) -> void:
	_state = v
	_state_obj.change(v)
