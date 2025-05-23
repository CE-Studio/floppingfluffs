extends RayCast3D


@onready var kerf: Kerfzel = $".."


func _physics_process(delta: float) -> void:
	position = kerf.global_position
	if is_colliding():
		kerf.apply_central_force(Vector3.UP * 20)
