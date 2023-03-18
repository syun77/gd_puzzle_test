extends Area2D

# ===========================
# グリッド(インデックス)座標系で動作するオブジェクトの既定.
# ===========================
class_name GridObject

# ---------------------------------------
# preload.
# ---------------------------------------


# ---------------------------------------
# vars.
# ---------------------------------------
var _point = Vector2i.ZERO
var _dir:int = Direction.eType.DOWN

# ---------------------------------------
# public functions.
# ---------------------------------------
## グリッド座標系を設定.	
func set_pos(i:int, j:int, is_center:bool) -> void:
  # グリッド座標系をワールド座標に変換して描画座標に反映する.
	position.x = Field.idx_to_world_x(i, is_center)
	position.y = Field.idx_to_world_y(j, is_center)

	# グリッド座標を設定.
	_point.x = i
	_point.y = j

## 方向を設定する.
func set_dir(dir:int) -> void:
	_dir = dir

## 指定の座標と一致しているかどうか.
func is_same_pos(i:int, j:int) -> bool:
	return _point.x == i and _point.y == j

## グリッド座標系のXを取得する.
func idx_x() -> int:
	return _point.x

## グリッド座標系のYを取得する.
func idx_y() -> int:
	return _point.y
