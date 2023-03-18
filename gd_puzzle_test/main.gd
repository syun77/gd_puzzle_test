extends Node2D
# ===========================
# メインシーン.
# ===========================

# ---------------------------------------
# preload.
# ---------------------------------------
const PLAYER_OBJ = preload("res://src/player/Player.tscn")
const CRATE_OBJ = preload("res://src/crate/Crate.tscn")
const KEY_OBJ = preload("res://src/key/Key.tscn")

enum eState {
	MAIN, # メイン.
	STAGE_CLEAR, # ステージクリア.
}

# ---------------------------------------
# onready.
# ---------------------------------------
# キャンバスレイヤー.
@onready var _tile_layer = $TileLayer
@onready var _obj_layer = $ObjLayer
@onready var _crate_layer = $CrateLayer

# ---------------------------------------
# vars.
# ---------------------------------------
var _timer = 0.0 # タイマー.
var _state = eState.MAIN # 状態.
var _player:Player = null

# ---------------------------------------
# private functions.
# ---------------------------------------
func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(1024*2, 600*2))
	
	# レベルを読み込む.
	var level_path = Common.get_level_scene()
	var level_res = load(level_path)
	var level_obj = level_res.instantiate()
	_tile_layer.add_child(level_obj)
	# タイルマップを取得する.
	var tilemap:TileMap = level_obj.get_node("./TileMap")
	
	# フィールドをセットアップする.
	Field.setup(tilemap)

	# タイルの情報からインスタンスを生成する.	
	for j in range(Field.TILE_HEIGHT):
		for i in range(Field.TILE_WIDTH):
			var data:TileData = tilemap.get_cell_tile_data(Field.eTileLayer.OBJECT, Vector2i(i, j))
			if data == null:
				continue
			
			var v = data.get_custom_data(Field.CUSTOM_NAME) as int
			if _create_obj(i, j, v):
				print("create obj: %d (%d, %d)"%[v, i, j])
				# 生成したらタイルの情報は消しておく.
				tilemap.set_cell(Field.eTileLayer.OBJECT, Vector2i(i, j), Field.eTile.NONE)
	
	# スタート地点が未設定の場合はランダムな位置にプレイヤーを出現させる.
	if _player == null:
		push_warning("プレイヤーの開始位置が設定されていません.")
		var p = Field.search_random_none()
		_create_player(p.x, p.y)
	
	# 共通モジュールをセットアップする.
	var layers = {
		"crate": _crate_layer,
	}
	Common.setup(_player, layers)

## タイル情報から生成されるオブジェクトをチェック＆生成.
func _create_obj(i:int, j:int, id:int) -> bool:
	match id:
		Field.eTile.START:
			# プレイヤー開始位置.
			_create_player(i, j)
			return true
		Field.eTile.CRATE1, Field.eTile.CRATE2, Field.eTile.CRATE3, Field.eTile.CRATE4:
			# 荷物.
			_create_crate(i, j, id)
			return true
		Field.eTile.KEY:
			# カギ.
			_create_keY(i, j)
			return true
	
	# 生成されていない.
	return false

## プレイヤーの生成.
func _create_player(i:int, j:int) -> void:
	_player = PLAYER_OBJ.instantiate()
	_player.set_pos(i, j, false)
	_obj_layer.add_child(_player)

## 荷物の生成.
func _create_crate(i:int, j:int, id:int) -> void:
	var crate = CRATE_OBJ.instantiate()
	# Spriteの更新があるので先に add_child() する.
	_crate_layer.add_child(crate)
	crate.setup(i, j, id)
	
## カギの生成.
func _create_keY(i:int, j:int) -> void:
	var key = KEY_OBJ.instantiate()
	_obj_layer.add_child(key)
	key.setup(i, j)

## 更新.
func _process(delta:float) -> void:
	match _state:
		eState.MAIN:
			_update_main(delta)
		eState.STAGE_CLEAR:
			_update_stage_clear()
	
## 更新 > メイン.
func _update_main(delta:float) -> void:
	_timer += delta
	
	if Input.is_action_just_pressed("ui_restart"):
		# リセットボタン.
		var _ret = get_tree().change_scene_to_file("res://Main.tscn")
	
	# プレイヤーの更新.
	_player.proc(delta)
	
	# 荷物の更新.
	for crate in _crate_layer.get_children():
		crate.proc(delta)
	
	# UIの更新.
	#_update_ui(delta)
	
## 更新 > ステージクリア.
func _update_stage_clear() -> void:
	# キャプションを表示する.
	#_ui_caption.visible = true
	#_ui_caption.text = "COMPLETED"
	if Common.is_final_level():
		#_ui_caption.text = "ALL LEVELS COMPLETED!"
		pass
	
	if Input.is_action_just_pressed("ui_accept"):
		# 次のステージに進む.
		Common.next_level()
		if Common.completed_all_level():
			# 全ステージクリアしたら最初から.
			Common.reset_level()
		var _ret = get_tree().change_scene_to_file("res://Main.tscn")
