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

# ===========================
# 2次元配列をグリッド操作用に拡張.
# ===========================
class Array2:
	# ----------------------------------------
	# 定数.
	# ----------------------------------------
	const EMPTY = 0 # 空とする値.
	const INVALID = -1 # 無効とする値.

	# ----------------------------------------
	# メンバ変数.
	# ----------------------------------------
	var width:int = 0
	var height:int = 0

	var _array := PackedInt32Array()

	# ----------------------------------------
	# メンバ関数.
	# ----------------------------------------
	# コンストラクタ.
	func _init(w:int=0, h:int=0) -> void:
		create(w, h)

	# 生成.	
	func create(w:int, h:int) -> void:
		_array = []
		for _i in range(w * h):
			_array.append(EMPTY)
		width = w
		height = h

	# コピーする.
	func copy_to(arr:Array2) -> void:
		arr.create(width, height)
	
	# 値をクリアする.
	func clear() -> void:
		fill(0)
		
	# 指定の値で埋める.
	func fill(v:int=EMPTY) -> void:
		_array.fill(v)

	# 指定の値が存在する数をカウントする.
	func count(v:int) -> int:
		return _array.count(v)

	# 値を交換する
	func swap(x1:int, y1:int, x2:int, y2:int) -> void:
		var v1 = getv(x1, y1)
		var v2 = getv(x2, y2)
		setv(x2, y2, v1)
		setv(x1, y1, v2)

	# インデックス(1次元)に変換する.
	func to_idx(i:int, j:int) -> int:
		return j * width + i

	# インデックスを(x, y)に変換する.
	func to_x(idx:int) -> int:
		return idx % width
	func to_y(idx:int) -> int:
		return idx / width
	func idx_to_pos(idx:int) -> Vector2i:
		var x = to_x(idx)
		var y = to_y(idx)
		return Vector2i(x, y)

	# 値を設定する.
	func setv(i:int, j:int, v:int) -> void:
		if _check(i, j) == false:
			return
		
		var idx = to_idx(i, j)
		_array[idx] = v

	# 値を取得する.
	func getv(i:int, j:int) -> int:
		if _check(i, j) == false:
			return INVALID
		
		var idx = to_idx(i, j)
		return _array[idx]

	# インデックスで値を設定する.	
	func set_idx(idx:int, v:int) -> void:
		if _check_idx(idx) == false:
			return
		_array[idx] = v

	# インデックスで値を取得する.
	func get_idx(idx:int) -> int:
		if _check_idx(idx) == false:
			return INVALID
		return _array[idx]

	# 有効な座標かどうかをチェックする.
	func _check(i:int, j:int) -> bool:
		if i < 0 or width <= i:
			return false
		if j < 0 or height <= j:
			return false
		# 有効.
		return true

	# インデックスが有効な座標かどうかをチェックする.
	func _check_idx(idx:int) -> bool:
		if idx < 0 or width*height <= idx:
			return false
		# 有効
		return true

	# 空白があったら落下させる.
	func fall() -> void:
		# 各列を下から調べる.
		for i in range(width):
			for j in range(height):
				j = height - j - 1
				var v = getv(i, j)
				if v != EMPTY:
					continue
				
				# 空なので上を調べる.
				for d in range(j):
					var y = j - (d + 1)
					var v2 = getv(i, y)
					if v2 == INVALID:
						break # 領域外
					if v2 != EMPTY:
						# 移動させる
						setv(i, j, v2)
						setv(i, y, EMPTY)
						break

	# 指定の値に一致する座標(インデックス)のリストを取得する.
	func search(v:int) -> PackedInt32Array:
		var ret := PackedInt32Array()
		for idx in range(width * height):
			if get_idx(idx) == v:
				ret.append(idx)
		return ret

	# デバッグ出力する.
	func dump() -> void:
		print("-------------------------")
		print("Array2.dump()")
		print("-------------------------")
		for j in range(height):
			var buf = ""
			for i in range(width):
				var v = getv(i, j)
				buf += "%2d "%v
			print(buf)
		print("-------------------------")
