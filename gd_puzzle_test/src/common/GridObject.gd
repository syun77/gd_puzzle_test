extends Area2D

# ===========================
# グリッド(インデックス)座標系で動作するオブジェクトの既定.
# ===========================
class_name GridObject

# ---------------------------------------
# preload.
# ---------------------------------------

# ---------------------------------------
# consts.
# --------------------------------------
enum eMove {
	DEFALUT,
	LINEAR,
}

# ---------------------------------------
# vars.
# ---------------------------------------
var _point = Vector2.ZERO
var _dir:int = Direction.eType.DOWN
var _prev_pos = Vector2i.ZERO
var _next_pos = Vector2i.ZERO

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
	return _point.x == i and _point.y == j

## グリッド座標系のXを取得する.
func idx_x() -> int:
	return _point.x

## グリッド座標系のYを取得する.
func idx_y() -> int:
	return _point.y

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
