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
	
	queue_redraw()
	
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

func _draw() -> void:
	var dir = Direction.to_vector(_dir)
	var pos = _point + dir
	while Field.is_outside(pos.x, pos.y) == false:
		if Field.can_move(pos.x, pos.y) == false:
			break
		pos += dir
	
	var p1 = Field.idx_to_world(_point + dir)
	var p2 = Field.idx_to_world(pos + (dir * 0.2))
	var color = Color.RED
	color.a = 0.8
	var rect = Rect2(p1-position, p2-p1)
	var size = (Field.TILE_SIZE * 0.5) * randf_range(0.7, 1)
	if rect.size.x == 0:
		# 上下.
		rect.size.x = size
		rect.position.x += (Field.TILE_SIZE/2) - (size/2)
	if rect.size.y == 0:
		# 左右.
		rect.size.y = size
		rect.position.y += (Field.TILE_SIZE/2) - (size/2)
	draw_rect(rect, color)
