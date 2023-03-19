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

const SOURCE_ID = 0

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
	PIT_OFF = 10, # 無効.
	PIT_ON = 11, # 有効.
	PIT2_OFF = 12, # 無効.
	PIT2_ON = 13, # 有効.

	# スイッチ.
	SWITCH_WHITE_OFF = 20, # 無効.
	SWITCH_WHITE_ON = 21, # 有効.
	SWITCH_RED_OFF = 22, # 無効.
	SWITCH_RED_ON = 23, # 有効.
	SWITCH_BLUE_OFF = 24, # 無効.
	SWITCH_BLUE_ON = 25, # 有効.
	SWITCH_GREEN_OFF = 26, # 無効.
	SWITCH_GREEN_ON = 27, # 有効.
	SWITCH_YELLOW_OFF = 28, # 無効.
	SWITCH_YELLOW_ON = 29, # 有効.
	SWITCH_OFF = 30, # 無効.
	SWITCH_ON = 31, # 有効.
	
	# 荷物
	CRATE1 = 50,
	CRATE2 = 51,
	CRATE3 = 52,
	CRATE4 = 53,
	
	# アイテム.
	KEY = 54,

	# 障害物.	
	SPIKE = 55,

	# プレイヤー
	START = 100, # 開始地点
	
	# 砲台.
	BATTERY_LEFT = 200, # 左.
	BATTERY_UP = 201, # 上.
	BATTERY_RIGHT = 202, # 右.
	BATTERY_DOWN = 203, # 下.
}

# ピットを切り替えるスイッチ.
const SWITCH_PIT_TBL = [eTile.SWITCH_OFF, eTile.SWITCH_ON]

## Atlas coords.
const ATLAS_COORDS_BLANK = Vector2i(1, 0)
const ATLAS_COORDS_PIT_OFF = Vector2i(3, 1)
const ATLAS_COORDS_PIT_ON = Vector2i(4, 1)
const ATLAS_COORDS_PIT2_OFF = Vector2i(5, 1)
const ATLAS_COORDS_PIT2_ON = Vector2i(6, 1)
const ATLAS_COORDS_SWITCH_WHITE_OFF = Vector2i(3, 2)
const ATLAS_COORDS_SWITCH_WHITE_ON = Vector2i(4, 2)
const ATLAS_COORDS_SWITCH_RED_OFF = Vector2i(3, 3)
const ATLAS_COORDS_SWITCH_RED_ON = Vector2i(4, 3)
const ATLAS_COORDS_SWITCH_BLUE_OFF = Vector2i(3, 4)
const ATLAS_COORDS_SWITCH_BLUE_ON = Vector2i(4, 4)
const ATLAS_COORDS_SWITCH_GREEN_OFF = Vector2i(3, 5)
const ATLAS_COORDS_SWITCH_GREEN_ON = Vector2i(4, 5)
const ATLAS_COORDS_SWITCH_YELLOW_OFF = Vector2i(3, 6)
const ATLAS_COORDS_SWITCH_YELLOW_ON = Vector2i(4, 6)
const ATLAS_COORDS_SWITCH_OFF = Vector2i(3, 7)
const ATLAS_COORDS_SWITCH_ON = Vector2i(4, 7)

const ATLAS_COORDS_TBL = {
	eTile.BLANK: ATLAS_COORDS_BLANK,
	# ピット.
	eTile.PIT_OFF: ATLAS_COORDS_PIT_OFF,
	eTile.PIT_ON: ATLAS_COORDS_PIT_ON,
	eTile.PIT2_OFF: ATLAS_COORDS_PIT2_OFF,
	eTile.PIT2_ON: ATLAS_COORDS_PIT2_ON,
	# スイッチ.
	eTile.SWITCH_WHITE_OFF: ATLAS_COORDS_SWITCH_OFF,
	eTile.SWITCH_WHITE_ON: ATLAS_COORDS_SWITCH_ON,
	eTile.SWITCH_RED_OFF: ATLAS_COORDS_SWITCH_OFF,
	eTile.SWITCH_RED_ON: ATLAS_COORDS_SWITCH_ON,
	eTile.SWITCH_BLUE_OFF: ATLAS_COORDS_SWITCH_OFF,
	eTile.SWITCH_BLUE_ON: ATLAS_COORDS_SWITCH_ON,
	eTile.SWITCH_GREEN_OFF: ATLAS_COORDS_SWITCH_OFF,
	eTile.SWITCH_GREEN_ON: ATLAS_COORDS_SWITCH_ON,
	eTile.SWITCH_YELLOW_OFF: ATLAS_COORDS_SWITCH_OFF,
	eTile.SWITCH_YELLOW_ON: ATLAS_COORDS_SWITCH_ON,
	eTile.SWITCH_OFF: ATLAS_COORDS_SWITCH_OFF, 
	eTile.SWITCH_ON: ATLAS_COORDS_SWITCH_ON, 
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

## スイッチかどうか.
func is_switch(tile:eTile) -> bool:
	var tbl = [
		# スイッチ.
		eTile.SWITCH_WHITE_OFF, # 無効.
		eTile.SWITCH_WHITE_ON, # 有効.
		eTile.SWITCH_RED_OFF, # 無効.
		eTile.SWITCH_RED_ON, # 有効.
		eTile.SWITCH_BLUE_OFF, # 無効.
		eTile.SWITCH_BLUE_ON, # 有効.
		eTile.SWITCH_GREEN_OFF, # 無効.
		eTile.SWITCH_GREEN_ON, # 有効.
		eTile.SWITCH_YELLOW_OFF, # 無効.
		eTile.SWITCH_YELLOW_ON, # 有効.
		eTile.SWITCH_OFF, # 無効.
		eTile.SWITCH_ON, # 有効.
	]
	return tile in tbl

## ピットかどうか.
func is_pit(tile:eTile) -> bool:
	var tbl = [eTile.PIT_OFF, eTile.PIT_ON, eTile.PIT2_OFF, eTile.PIT2_ON]
	return tile in tbl

# ---------------------------------------
# vars.
# ---------------------------------------
var _tile:TileMap = null
var _laser_map = Common.Array2.new(TILE_WIDTH, TILE_HEIGHT)
var _block_map = Common.Array2.new(TILE_WIDTH, TILE_HEIGHT)

# ---------------------------------------
# public functions.
# ---------------------------------------
## セットアップ.
func setup(tile:TileMap) -> void:
	_tile = tile

## フィールドの場外かどうか.
func is_outside(i:int, j:int) -> bool:
	if i < 0 or j < 0:
		return true
	if i >= TILE_WIDTH or j >= TILE_HEIGHT:
		return true
	return false

func get_cell(i:int, j:int) -> int:
	var data = _tile.get_cell_tile_data(eTileLayer.BACKGROUND, Vector2i(i, j))
	if data == null:
		return eTile.NONE
	var v:int = data.get_custom_data(CUSTOM_NAME)
	return v

func set_cell(i:int, j:int, v:eTile) -> void:
	if not v in ATLAS_COORDS_TBL:
		assert(0, "不明なタイルID:%d"%v)
	var atlas_coords = ATLAS_COORDS_TBL[v]
	_tile.set_cell(eTileLayer.BACKGROUND, Vector2i(i, j), SOURCE_ID, atlas_coords)
		
func erase_cell(i:int, j:int) -> void:
	_tile.set_cell(eTileLayer.BACKGROUND, Vector2i(i, j), SOURCE_ID, ATLAS_COORDS_BLANK)

## スイッチの状態チェック.
func switch_check(i:int, j:int) -> bool:
	var v = get_cell(i, j)
	if is_switch(v) == false:
		return false# スイッチでない.
	return v%2 == 1

## スイッチON.
func switch_on(i:int, j:int) -> void:
	var v = get_cell(i, j)
	if is_switch(v) == false:
		return # スイッチでない.
	if v%2 == 0:
		toggle_switch(i, j) # OFF -> ON
	
## スイッチOFF.
func switch_off(i:int, j:int) -> void:
	var v = get_cell(i, j)
	if is_switch(v) == false:
		return # スイッチでない.
	if v%2 == 1:
		toggle_switch(i, j) # ON -> OFF

## スイッチのON/OFF切り替え.
func toggle_switch(i:int, j:int) -> void:
	var v = get_cell(i, j)
	if is_switch(v) == false:
		return # スイッチでない.
	if v%2 == 0:
		v += 1 # OFF -> ON
	else:
		v -= 1 # ON -> OFF
	
	if v in SWITCH_PIT_TBL:
		# ピットの状態を切り替え.
		for y in range(TILE_HEIGHT):
			for x in range(TILE_WIDTH):
				toggle_pit(x, y)
	
	set_cell(i, j, v)

## ピットの状態をトグルする.
func toggle_pit(i:int, j:int) -> void:
	var v = get_cell(i, j)
	if is_pit(v) == false:
		return # ピットでない.
	if v%2 == 0:
		v += 1 # OFF -> ON
	else:
		v -= 1 # ON -> OFF
	set_cell(i, j, v)

## 移動可能な位置かどうか.
func can_move(i:int, j:int) -> bool:
	var v = get_cell(i, j)
	if v in [eTile.BLOCK, eTile.LOCK]:
		return false # 壁がある.
	
	if exists_crate(i, j):
		return false # 荷物がある.
	
	if exists_battery(i, j):
		return false # 砲がある.
	
	return true

## 砲台があるかどうか.
func exists_battery(i:int, j:int) -> bool:
	if search_battery(i, j) != null:
		return true
	return false
func search_battery(i:int, j:int) -> Battery:
	for obj in Common.get_layer("obj").get_children():
		if not obj is Battery:
			continue # 砲台でない.
		if obj.is_same_pos(i, j):
			return obj # 存在する.
	
	return null # 存在しない.
## 荷物があるかどうか.
func exists_crate(i:int, j:int) -> bool:
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
	
	if exists_crate(i, j) == false:
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
func idx_to_world(p:Vector2, is_center:bool=false) -> Vector2:
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

## レーザーヒットマップを消去.
func clear_laser_map() -> void:
	_laser_map.clear()
## レーザーヒットマップのフラグを立てる.
func biton_laser_map(i:int, j:int) -> void:
	_laser_map.setv(i, j, 1)
## 指定の位置にフラグが立っているかどうかを調べる.
func bitchk_laser_map(i:int, j:int) -> bool:
	return _laser_map.getv(i, j) != 0

## ブロックマップを消去.
func clear_block_map() -> void:
	_block_map.clear()
## ブロックマップのフラグを立てる.
func biton_block_map(i:int, j:int) -> void:
	_block_map.setv(i, j, 1)
## 指定の位置にフラグが立っているかどうかを調べる.
func bitchk_block_map(i:int, j:int) -> bool:
	return _block_map.getv(i, j) != 0


# ---------------------------------------
# private functions.
# ---------------------------------------
