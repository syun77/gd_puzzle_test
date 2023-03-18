extends Node
# ===========================
# 共通モジュール.
# ===========================
# ---------------------------------------
# preload.
# ---------------------------------------

# ---------------------------------------
# const.
# ---------------------------------------
# 最初のレベル.
const FIRST_LEVEL = 1
# 最終レベル.
const FINAL_LEVEL = 3

# ---------------------------------------
# class.
# ---------------------------------------

# ---------------------------------------
# vars.
# ---------------------------------------
var _player:Player = null
var _layers = []
var _level = FIRST_LEVEL

# ---------------------------------------
# public functions.
# ---------------------------------------
## レベルを最初に戻す.
func reset_level() -> void:
	_level = FIRST_LEVEL
## レベルを次に進める.
func next_level() -> void:
	_level += 1
## 最終レベルを終えたかどうか.
func completed_all_level() -> bool:
	return _level > FINAL_LEVEL
func is_final_level() -> bool:
	return _level == FINAL_LEVEL
## 現在のレベル番号を取得する.
func get_level() -> int:
	return _level
## レベルシーンのパスを取得する.
func get_level_scene(level:int=0) -> String:
	if level <= 0:
		# 指定がない場合は現在のレベルを使用する.
		level = _level
	
	return "res://src/level/level%02d.tscn"%level

## セットアップ.
func setup(player, layers):
	_player = player
	_layers = layers

## CanvasLayerを取得する.
func get_layer(name:String) -> CanvasLayer:
	return _layers[name]

# ---------------------------------------
# private functions.
# ---------------------------------------
