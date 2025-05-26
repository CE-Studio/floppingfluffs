extends Control

@onready var texture_rect: TextureRect = $TextureRect

var direction := Vector2(1, 1)  
var speed := Vector2(2, 2)     

var screen_size := Vector2.ZERO

func _ready() -> void:
	visible = false
	set_process(false)
	screen_size = get_viewport_rect().size

func activate():
	visible = true
	set_process(true)
	direction = Vector2(sign(randf() - 0.5), sign(randf() - 0.5)).normalized()

func _process(_delta: float) -> void:
	var pos = texture_rect.position
	var size = texture_rect.size
	pos.x += direction.x * speed.x
	pos.y += direction.y * speed.y
	if pos.x <= 0 or pos.x + size.x >= screen_size.x:
		direction.x *= -1
		pos.x = clamp(pos.x, 0, screen_size.x - size.x)
	if pos.y <= 0 or pos.y + size.y >= screen_size.y:
		direction.y *= -1
		pos.y = clamp(pos.y, 0, screen_size.y - size.y)
	texture_rect.position = pos
