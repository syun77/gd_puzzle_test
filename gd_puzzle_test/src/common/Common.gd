extends Node
# ===========================
# 共通モジュール.
# ===========================

# ---------------------------------------
# const.
# ---------------------------------------
# 最初のレベル.
const FIRST_LEVEL = 1
# 最終レベル.
const FINAL_LEVEL = 3

# ---------------------------------------
# preload.
# ---------------------------------------
const PARTICLE_OBJ = preload("res://src/effect/Particle.tscn")

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
	
func add_particle() -> Particle:
	var parent = get_layer("effect")
	var p = PARTICLE_OBJ.instantiate()
	parent.add_child(p)
	return p

func start_particle(pos:Vector2, time:float, color:Color, sc:float=1.0) -> void:
	var deg = randf_range(0, 360)
	for i in range(8):
		var p = add_particle()
		p.position = pos
		var speed = randf_range(100, 1000)
		var t = time + randf_range(-0.2, 0.2)
		p.start(t, deg, speed, 0, 10, color, sc)
		deg += randf_range(30, 50)

func start_particle_ring(pos:Vector2, time:float, color:Color, sc:float=2.0) -> void:
	var p = add_particle()
	p.position = pos
	p.start_ring(time, color, sc)

func start_particle_enemy(pos:Vector2, time:float, color:Color) -> void:
	start_particle(pos, time, color, 2.0)
	for i in range(3):
		start_particle_ring(pos, time + (i * 0.2), color, pow(2.0, (1 + i)))

# ---------------------------------------
# private functions.
# ---------------------------------------
