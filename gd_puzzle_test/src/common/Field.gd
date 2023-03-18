extends Node
# ===========================
# フィールド関連.
# ===========================

# ---------------------------------------
# preload.
# ---------------------------------------

# ---------------------------------------
# const.
# ---------------------------------------
const TILE_SIZE = 64.0

const FIELD_OFS_X = 0
const FIELD_OFS_Y = 0
const TILE_WIDTH = 12
const TILE_HEIGHT = 8

# ---------------------------------------
# enum.
# ---------------------------------------
enum eTileLayer {
	BACKGROUND = 0, # 背景.
	OBJECT = 1, # オブジェクト.
	
	MAX
}

enum eTile {
	NONE = -1,
	
	BLANK = 0, # 通路
	BLOCK = 1, # 壁
	
	# 荷物
	CRATE1 = 10,
	CRATE2 = 11,
	CRATE3 = 12,
	CRATE4 = 13,

	# プレイヤー
	START = 20, # 開始地点
}

# ---------------------------------------
# vars.
# ---------------------------------------
var _tile:TileMap = null

# ---------------------------------------
# public functions.
# ---------------------------------------
## セットアップ.
func setup(tile:TileMap) -> void:
	_tile = tile

func get_cell(i:int, j:int) -> int:
	return _tile.get_cell_source_id(0, Vector2i(i, j))

## 移動可能な位置かどうか.
func can_move(i:int, j:int) -> bool:
	match get_cell(i, j):
		eTile.BLOCK:
			return false # 壁がある.
		_:
			if is_crate(i, j):
				return false # 荷物がある.
			return true

## 荷物があるかどうか.
func is_crate(i:int, j:int) -> bool:
	if search_crate(i, j) != null:
		return true
	return false

## 荷物を探す.
## @return 荷物オブジェクト(Crate)。循環参照になるので型は指定できない.
func search_crate(i:int, j:int):
	for crate in Common.get_layer("crate").get_children():
		if crate.is_same_pos(i, j):
			return crate # 存在する.
	
	return null # 存在しない.
	

## 荷物を動かせるかどうか.
func can_move_crate(i:int, j:int, dx:int, dy:int) -> bool:
	# 移動先をチェックする.
	if can_move(i+dx, j+dy) == false:
		return false # 動かせない.
	
	if is_crate(i, j) == false:
		return false # 指定した位置に荷物がない.
	
	return true # 動かせる.
	
## 荷物を動かす.
func move_crate(i:int, j:int, dx:int, dy:int) -> void:
	var crate = search_crate(i, j)
	var xnext = i + dx
	var ynext = j + dy
	crate.set_pos(xnext, ynext, true)

## インデックスX座標をワールドX座標に変換する.
func idx_to_world_x(i:int, is_center:bool=false) -> float:
	var i2 = i
	if is_center:
		i2 += 0.5	
	return FIELD_OFS_X + (i2 * TILE_SIZE)
## インデックスY座標をワールドY座標に変換する.
func idx_to_world_y(j:int, is_center:bool=false) -> float:
	var j2 = j
	if is_center:
		j2 += 0.5	
	return FIELD_OFS_Y + (j2 * TILE_SIZE)
## インデックス座標系をワールド座標系に変換する.
func idx_to_world(p:Vector2i, is_center:bool=false) -> Vector2:
	var v = Vector2()
	v.x = idx_to_world_x(p.x, is_center)
	v.y = idx_to_world_y(p.y, is_center)
	return v

## 何もない場所をランダムで返す.
func search_random_none() -> Vector2i:
	var arr = []
	for j in range(TILE_HEIGHT):
		for i in range(TILE_WIDTH):
			var canPut = true
			for k in range(Field.eTileLayer.MAX):
				var data:TileData = _tile.get_cell_tile_data(Field.eTileLayer.BACKGROUND, Vector2i(i, j))
				var v = data.get_custom_data("Terrain")
				if v == eTile.NONE:
					canPut = false # 何かがある
			if canPut:
				arr.append(Vector2i(i, j))
	
	arr.shuffle()
	return arr[0]

# ---------------------------------------
# private functions.
# ---------------------------------------
