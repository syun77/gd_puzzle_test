extends GridObject
# ===========================
# 荷物オブジェクト.
# ===========================
class_name Crate
# ---------------------------------------
# preload.
# ---------------------------------------

# ---------------------------------------
# const.
# ---------------------------------------

# ---------------------------------------
# enum.
# ---------------------------------------
enum eType {
	BROWN = Field.eTile.CRATE1,
	RED = Field.eTile.CRATE2,
	BLUE = Field.eTile.CRATE3,
	GREEN = Field.eTile.CRATE4,
}

# ---------------------------------------
# onready.
# ---------------------------------------
@onready var _spr = $Sprite

# ---------------------------------------
# vars.
# ---------------------------------------
var _type = eType.BROWN
var _request_move = false # 移動要求.

# ---------------------------------------
# public functions.
# ---------------------------------------
## 荷物の種類を取得する.
func get_type() -> int:
	return _type

## セットアップ.
func setup(i:int, j:int, type:int) -> void:
	_type = type
	_spr.frame = _get_anim_idx()
	set_pos(i, j, false)

## 動かせるかどうか.
func can_move() -> bool:
	if _state != eState.STANDBY:
		return false # 動かせない.
	return true

## 移動要求.
func request_move(i:int, j:int) -> bool:
	if can_move() == false:
		return false
	
	_request_move = true
	_prev_pos = _point
	_next_pos.x = i
	_next_pos.y = j
	
	# 要求判定.
	proc(0)
	return true

## 更新
func proc(delta: float) -> void:
	
	update_state()
	pre_update()
	match _state:
		eState.STANDBY:
			_update_standby(delta)
		eState.MOVING:
			update_moving(delta)
		eState.CONVEYOR_BELT:
			update_conveyor_belt(delta)
	post_update()
	
# ---------------------------------------
# private functions.
# ---------------------------------------
func _ready() -> void:
	pass

## 更新 > 停止中.
func _update_standby(delta:float) -> void:
	if check_conveyor_belt():
		# ベルトコンベアを踏んだ.
		_timer = 0
		_state = eState.CONVEYOR_BELT
		return
				
	if _request_move:
		_request_move = false
		_timer = 0
		_state = eState.MOVING

## 種別に対応するスプライトフレーム番号を取得する
func _get_anim_idx() -> int:
	match _type:
		eType.BROWN:
			return 0
		eType.RED:
			return 1
		eType.BLUE:
			return 2
		_: # eType.GREEN:
			return 3
