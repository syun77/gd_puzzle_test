extends GridObject
# ===========================
# 砲台オブジェクト.
# ===========================
class_name Battery
# ---------------------------------------
# preload.
# ---------------------------------------

# ---------------------------------------
# const.
# ---------------------------------------

# ---------------------------------------
# enum.
# ---------------------------------------

# ---------------------------------------
# onready.
# ---------------------------------------
@onready var _spr = $Sprite

# ---------------------------------------
# vars.
# ---------------------------------------
var _anim_timer = 0.0

# ---------------------------------------
# public functions.
# ---------------------------------------

## セットアップ.
func setup(i:int, j:int, type:int) -> void:
	match type:
		Field.eTile.BATTERY_LEFT:
			_dir = Direction.eType.LEFT
		Field.eTile.BATTERY_UP:
			_dir = Direction.eType.UP
		Field.eTile.BATTERY_RIGHT:
			_dir = Direction.eType.RIGHT
		Field.eTile.BATTERY_DOWN:
			_dir = Direction.eType.DOWN
			
	_spr.frame = _get_anim_idx()
	set_pos(i, j, false)

## 動かせるかどうか.
func can_move() -> bool:
	if _state != eState.STANDBY:
		return false # 動かせない.
	return true

## 更新
func proc(delta: float) -> void:
	_anim_timer += delta
	
	update_state()
	pre_update()
	_update_standby(delta)
	post_update()
	
	var idx = _get_anim_idx()
	var anim_tbl = [0, 1, 2, 1]
	var ofs = (int(_anim_timer*4)%anim_tbl.size())
	_spr.frame = idx + (4 * anim_tbl[ofs])
	
# ---------------------------------------
# private functions.
# ---------------------------------------
func _ready() -> void:
	pass

## 更新 > 停止中.
func _update_standby(delta:float) -> void:
	pass

## 方向に対応するスプライトフレーム番号を取得する
func _get_anim_idx() -> int:
	match _dir:
		Direction.eType.DOWN:
			return 0
		Direction.eType.LEFT:
			return 1
		Direction.eType.UP:
			return 2
		_: # Direction.eType.RIGHT:
			return 3
