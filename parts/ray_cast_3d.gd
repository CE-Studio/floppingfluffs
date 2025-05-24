extends RayCast3D


@onready var kerf: Kerfzel = $".."

@export var power: float = 5


var upright_strength = 1.0
var offset: Vector3


func _ready() -> void:
	DebugMenu.Register("damp", func(): return kerf.angular_damp)


func _physics_process(delta: float) -> void:
	global_rotation = Vector3.ZERO

	force_raycast_update()
	
	if is_colliding():
		
		kerf.apply_central_force(Vector3.UP * power * randf_range(.5, 2.0))
		var up_direction = kerf.global_transform.basis.y.normalized()
		var torque_axis = up_direction.cross(Vector3.UP)
		var angle_difference = up_direction.angle_to(Vector3.UP)

		var corrective_torque = torque_axis.normalized() * angle_difference * upright_strength
		kerf.apply_torque(corrective_torque) 
