extends Camera3D

@export var mouse_sensitivity: float = 0.002
var pivot_speed: float = 0;
@export var pivot_damp: float = 6
@export var grab_distance: float = 10.0
var grab_distance_dynamic: float;

@onready var pivot: SpringArm3D = get_parent()

var grabbed_object: RigidBody3D = null
var spring_strength: float = 100.0
var damping: float = 10.0

func _ready() -> void:
	DebugMenu.Register("Speed", func(): return pivot_speed)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	# Mouse wheel zoom
	if Input.is_action_just_released("zoom_in"):
		pivot.spring_length = clamp(pivot.spring_length - .5, 2.0, 20.0)
	elif Input.is_action_just_released("zoom_out"):
		pivot.spring_length = clamp(pivot.spring_length + .5, 2.0, 20.0)
	
	pivot_speed = lerpf(pivot_speed, 0, pivot_damp * delta)
	pivot.rotation.y += pivot_speed

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("grab"):
		try_grab()
	elif Input.is_action_just_released("grab"):
		grabbed_object = null

	if grabbed_object:
		var target_pos = get_ray_target_position()
		var to_target = target_pos - grabbed_object.global_position

		var distance = to_target.length()
		var direction = to_target.normalized()

		var velocity = grabbed_object.linear_velocity
		var force = direction * (spring_strength * distance) - velocity * damping

		grabbed_object.apply_central_force(force)


func _input(event: InputEvent) -> void:
	# Toggle mouse mode
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Rotate camera pivot with mouse
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		pivot_speed += -event.relative.x * mouse_sensitivity
		#rotation.x += -event.relative.y * mouse_sensitivity
		#rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(89))


func try_grab() -> void:
	var origin = get_ray().origin
	var direction = get_ray().direction
	var target = origin + direction * grab_distance

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, target)
	query.collision_mask = 1  # TODO: Customize this as needed

	var result = space_state.intersect_ray(query)
	if result and result.has("collider") and result["collider"] is RigidBody3D:
		grabbed_object = result["collider"]
		grab_distance_dynamic = (result["position"] - origin).length()


func get_ray() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = project_ray_origin(mouse_pos)
	var direction = project_ray_normal(mouse_pos)
	return {
		"origin": origin,
		"direction": direction
	}


func get_ray_target_position() -> Vector3:
	var ray = get_ray()
	return ray.origin + ray.direction * grab_distance_dynamic
