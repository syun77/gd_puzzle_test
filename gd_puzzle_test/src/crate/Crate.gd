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
enum eState {
	STANDBY,
	MOVING,
}

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
var _timer = 0.0
var _state := eState.STANDBY
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

## 移動要求.
func request_move(i:int, j:int) -> void:
	_request_move = true
	_prev_pos = _point
	_next_pos.x = i
	_next_pos.y = j
	
	# 要求判定.
	proc(0)

## 更新
func proc(delta: float) -> void:
	match _state:
		eState.STANDBY:
			_update_standby(delta)
		eState.MOVING:
			_update_moving(delta)

# ---------------------------------------
# private functions.
# ---------------------------------------
func _ready() -> void:
	pass

## 更新 > 停止中.
func _update_standby(delta:float) -> void:
	if _request_move:
		_request_move = false
		_timer = 0
		_state = eState.MOVING

func _update_moving(delta:float) -> void:
	_timer = update_move(_timer, delta)
	if _timer >= 1:
		set_pos(_next_pos.x, _next_pos.y, false)
		_state = eState.STANDBY
	else:
		set_pos(_point.x, _point.y, false)		
	
	
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
