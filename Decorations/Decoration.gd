extends Node3D
class_name StaticDecoration

var placed: bool = false

@onready var rigid_body: RigidBody3D = $Rigid
@onready var static_body: StaticBody3D = $StaticBody
@onready var rigid_body_3d: RigidBody3D = $StaticBody/RigidBody3D
@onready var ground: RayCast3D = $Rigid/Ground
@onready var hinge_joint_3d: HingeJoint3D = $StaticBody/HingeJoint3D

func set_speed(speed: float):
	print("im changin the speed")
	rigid_body_3d.constant_torque = Vector3(0,speed/2, 0)

func _ready() -> void:
	placed = false

	set_rigid_body_enabled(rigid_body_3d, false, 3)
	set_rigid_body_enabled(rigid_body, true, 1)
	set_static_body_enabled(static_body, false)

func is_placed() -> bool:
	return placed

func place():
	if placed:
		return
	placed = true
	
	static_body.global_position = rigid_body.global_position

	ground.enabled = true
	ground.global_rotation = Vector3.ZERO
	ground.force_update_transform()
	await get_tree().physics_frame
	if ground.is_colliding():
		static_body.global_position = ground.get_collision_point()

	set_rigid_body_enabled(rigid_body, false, 1)
	set_static_body_enabled(static_body, true)
	set_rigid_body_enabled(rigid_body_3d, true, 3)

func pickup():
	if not placed:
		return
	placed = false

	rigid_body.global_transform = static_body.global_transform

	set_rigid_body_enabled(rigid_body, true, 1)
	set_rigid_body_enabled(rigid_body_3d, false, 3)
	set_static_body_enabled(static_body, false)

func set_rigid_body_enabled(body: RigidBody3D, enabled: bool, layer: int) -> void:
	body.sleeping = not enabled
	body.freeze = not enabled
	body.visible = enabled
	body.set_physics_process(enabled)
	body.collision_layer = layer if enabled else 0
	body.collision_mask = int(enabled)

func set_static_body_enabled(body: StaticBody3D, enabled: bool) -> void:
	body.visible = enabled
	body.set_physics_process(enabled)
	body.collision_layer = 2 if enabled else 0
	body.collision_mask = int(enabled)
