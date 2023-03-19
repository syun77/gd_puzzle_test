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
const TILE_WIDTH = 18
const TILE_HEIGHT = 10

const CUSTOM_NAME = "Terrain"

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
	LOCK  = 2, # カギのかかった扉.
	
	# ベルトコンベア.
	CONVEYOR_BELT_L = 3, # 左.
	CONVEYOR_BELT_U = 4, # 上.
	CONVEYOR_BELT_R = 5, # 右.
	CONVEYOR_BELT_D = 6, # 下.
	
	# ピット
	PIT_OFF = 7, # 無効.
	PIT_ON = 8, # 有効.
	
	# 荷物
	CRATE1 = 10,
	CRATE2 = 11,
	CRATE3 = 12,
	CRATE4 = 13,
	
	# アイテム.
	KEY = 15,
	
	SPIKE = 16,

	# プレイヤー
	START = 20, # 開始地点
}

## ベルトコンベアかどうか.
func is_conveyor_belt(tile:eTile) -> bool:
	var tbl = [
		eTile.CONVEYOR_BELT_L, # 左.
		eTile.CONVEYOR_BELT_U, # 上.
		eTile.CONVEYOR_BELT_R, # 右.
		eTile.CONVEYOR_BELT_D, # 下.
	]
	return tile in tbl
func conveyor_belt_to_dir(tile:eTile) -> Direction.eType:
	var tbl = {
		eTile.CONVEYOR_BELT_L: Direction.eType.LEFT, # 左.
		eTile.CONVEYOR_BELT_U: Direction.eType.UP, # 上.
		eTile.CONVEYOR_BELT_R: Direction.eType.RIGHT, # 右.
		eTile.CONVEYOR_BELT_D: Direction.eType.DOWN, # 下.
	}
	return tbl[tile]

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
	var data = _tile.get_cell_tile_data(eTileLayer.BACKGROUND, Vector2i(i, j))
	if data == null:
		return eTile.NONE
	var v:int = data.get_custom_data(CUSTOM_NAME)
	return v

func erase_cell(i:int, j:int) -> void:
	var source_id = 0
	var atlas_coords = Vector2i(1, 0)
	_tile.set_cell(eTileLayer.BACKGROUND, Vector2i(i, j), source_id, atlas_coords)

## 移動可能な位置かどうか.
func can_move(i:int, j:int) -> bool:
	match get_cell(i, j):
		eTile.BLOCK, eTile.LOCK:
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
func move_crate(i:int, j:int, dx:int, dy:int) -> bool:
	var crate = search_crate(i, j)
	var xnext = i + dx
	var ynext = j + dy
	return crate.request_move(xnext, ynext)

## インデックスX座標をワールドX座標に変換する.
func idx_to_world_x(i:float, is_center:bool=false) -> float:
	var i2 = i
	if is_center:
		i2 += 0.5	
	return FIELD_OFS_X + (i2 * TILE_SIZE)
## インデックスY座標をワールドY座標に変換する.
func idx_to_world_y(j:float, is_center:bool=false) -> float:
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
	print("ランダムな場所に出現させます")
	var arr = []
	for j in range(TILE_HEIGHT):
		for i in range(TILE_WIDTH):
			var canPut = true
			for k in range(Field.eTileLayer.MAX):
				var data:TileData = _tile.get_cell_tile_data(Field.eTileLayer.BACKGROUND, Vector2i(i, j))
				var v = data.get_custom_data(Field.CUSTOM_NAME)
				if v == eTile.NONE:
					canPut = false # 何かがある
			if canPut:
				arr.append(Vector2i(i, j))
	
	arr.shuffle()
	return arr[0]

# ---------------------------------------
# private functions.
# ---------------------------------------
