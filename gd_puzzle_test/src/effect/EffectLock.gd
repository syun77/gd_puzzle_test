extends Sprite2D

const TIMER = 0.5
const SPEED_DECAY = 0.9
const GRAVITY = 30.0

var _timer = 0.0
var _velocity = Vector2.ZERO

## セットアップ.
func setup(pos:Vector2) -> void:
	position = Field.idx_to_world(pos, true)
	_velocity.x = randf_range(-200, 200)
	_velocity.y = -300

## 更新.
func _physics_process(delta):
	_timer += delta
	_velocity.y += GRAVITY
	_velocity *= SPEED_DECAY
	position += _velocity * delta
	
	visible = int(_timer*20)%2 == 0
	
	rotation += delta * 8
	if _timer > TIMER:
		queue_free()
