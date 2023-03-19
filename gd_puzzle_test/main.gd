extends Node2D
# ===========================
# メインシーン.
# ===========================
# ---------------------------------------
# const.
# ---------------------------------------
const TIMER_SHAKE = 0.5

# ---------------------------------------
# preload.
# ---------------------------------------
const PLAYER_OBJ = preload("res://src/player/Player.tscn")
const CRATE_OBJ = preload("res://src/crate/Crate.tscn")
const KEY_OBJ = preload("res://src/key/Key.tscn")
const SPIKE_OBJ = preload("res://src/spike/Spike.tscn")
const BATTERY_OBJ = preload("res://src/battery/Battery.tscn")

enum eState {
	MAIN, # メイン.
	STAGE_CLEAR, # ステージクリア.
	WAIT, # 少し待つ.
	GAME_OVER, # ゲームオーバー.
}

# ---------------------------------------
# onready.
# ---------------------------------------
# オブジェクト.
@onready var _camera = $Camera2D
# UI.
@onready var _ui_caption = $UILayer/Caption
# キャンバスレイヤー.
@onready var _tile_layer = $TileLayer
@onready var _obj_layer = $ObjLayer
@onready var _effect_layer = $EffectLayer
@onready var _crate_layer = $CrateLayer

# ---------------------------------------
# vars.
# ---------------------------------------
var _timer = 0.0 # タイマー.
var _state = eState.MAIN # 状態.
var _player:Player = null
var _timer_shake = 0.0
var _goal_pos = Vector2i.ONE * -1 # ゴールの位置.

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
	
	# ゴールの位置を探す.
	_goal_pos = Field.search_goal()
	
	# 共通モジュールをセットアップする.
	var layers = {
		"tile": _tile_layer,
		"crate": _crate_layer,
		"obj": _obj_layer,
		"effect": _effect_layer,
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
			_create_key(i, j)
			return true
		Field.eTile.SPIKE:
			# トゲ.
			_create_spike(i, j)
			return true
		Field.eTile.BATTERY_LEFT, Field.eTile.BATTERY_UP, Field.eTile.BATTERY_RIGHT, Field.eTile.BATTERY_DOWN:
			# 砲台.
			_create_battery(i, j, id)
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
func _create_key(i:int, j:int) -> void:
	var key = KEY_OBJ.instantiate()
	_obj_layer.add_child(key)
	key.setup(i, j)
	
## トゲの生成.
func _create_spike(i:int, j:int) -> void:
	var spike = SPIKE_OBJ.instantiate()
	_obj_layer.add_child(spike)
	spike.setup(i, j)

## 砲台の生成.
func _create_battery(i:int, j:int, id:Field.eTile) -> void:
	var battery = BATTERY_OBJ.instantiate()
	_obj_layer.add_child(battery)
	battery.setup(i, j, id)

## 更新.
func _process(delta:float) -> void:
	match _state:
		eState.MAIN:
			_update_main(delta)
		eState.STAGE_CLEAR:
			_update_stage_clear(delta)
		eState.WAIT:
			_update_wait(delta)
		eState.GAME_OVER:
			_update_gameover(delta)
			
	if Input.is_action_just_pressed("ui_restart"):
		# リセットボタン.
		var _ret = get_tree().change_scene_to_file("res://Main.tscn")
	
## 更新 > メイン.
func _update_main(delta:float) -> void:
	_timer += delta
	
	if _player.request_kill:
		# ゲームオーバー.
		_state = eState.WAIT
		_timer = 0
		return
	
	# プレイヤーの更新.
	_player.proc(delta)
	
	# レーザーマップの初期化.
	Field.clear_laser_map()
	# ブロックマップの初期化.
	Field.clear_block_map()
	
	# オブジェクトの更新.
	_update_objects(delta)
	
	# 荷物の更新.
	for crate in _crate_layer.get_children():
		crate.proc(delta)
	
	# UIの更新.
	#_update_ui(delta)
	
	# ゴール判定.
	if _player.is_standby():
		if _player.is_same_pos(_goal_pos.x, _goal_pos.y):
			_timer = 0
			_state = eState.STAGE_CLEAR

## オブジェクトの更新 (プレイヤーは除外).
func _update_objects(delta:float) -> void:
	for obj in _obj_layer.get_children():
		if obj is Player:
			continue # プレイヤは除外.
		if obj.has_method("proc"):
			obj.proc(delta)

## 更新 > ステージクリア.
func _update_stage_clear(delta:float) -> void:
	_timer += delta
	# オブジェクトの更新.
	_update_objects(delta)
	
	# キャプションを表示する.
	_ui_caption.visible = true
	_ui_caption.text = "COMPLETED"
	_ui_caption.visible_ratio = 1
	if _timer < 1:
		return # 演出中.
		
	if Common.is_final_level():
		_ui_caption.text = "ALL LEVELS COMPLETED!"
		pass
	
	if Input.is_action_just_pressed("ui_accept"):
		# 次のステージに進む.
		Common.next_level()
		if Common.completed_all_level():
			# 全ステージクリアしたら最初から.
			Common.reset_level()
		var _ret = get_tree().change_scene_to_file("res://Main.tscn")

func _update_wait(delta:float) -> void:
	_player.proc(delta)
	_timer += delta
	if _timer > 0.5:
		_player.vanish()
		_start_gameover()

func _update_gameover(delta:float) -> void:
	# オブジェクトの更新.
	_update_objects(delta)
	_ui_caption.visible_ratio += delta
	
	if _timer_shake > 0:
		_timer_shake -= delta
		var t = (_timer_shake / TIMER_SHAKE)
		var n = int(t*15)
		var dx = 48 * t
		if n%2 == 0:
			dx *= -1
		_camera.offset.x = dx
		_camera.offset.y = randf_range(-24*t, 24*t)
		
		if _timer_shake <= 0:
			_camera.offset = Vector2.ZERO

func _start_gameover() -> void:
	_ui_caption.visible_ratio = 0
	_ui_caption.visible = true
	_state = eState.GAME_OVER
	
	_timer_shake = TIMER_SHAKE
