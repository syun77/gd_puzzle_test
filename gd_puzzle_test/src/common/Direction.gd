extends Node
# ===========================
# 方向を扱う.
# ===========================

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
	NONE,
	
	LEFT,
	UP,
	RIGHT,
	DOWN,
}
# ---------------------------------------
# public functions.
# ---------------------------------------
func to_vector(type:int) -> Vector2i:
	match type:
		eType.LEFT:
			return Vector2i.LEFT
		eType.UP:
			return Vector2i.UP
		eType.RIGHT:
			return Vector2i.RIGHT
		_:
			return Vector2i.DOWN

func to_name(type:int) -> String:
	match type:
		eType.LEFT:
			return "LEFT"
		eType.UP:
			return "UP"
		eType.RIGHT:
			return "RIGHT"
		eType.DOWN:
			return "DOWN"
		_:
			return "NONE"
# ---------------------------------------
# private functions.
# ---------------------------------------
