class_name PlayerCam
extends Camera3D

@export var mouse_sensitivity: Vector2 = Vector2(0.002, 0.001)
var pivot_speed: Vector2 = Vector2.ZERO;
@export var pivot_damp: float = 6
@export var grab_distance: float = 100.0
var grab_distance_dynamic: float;

@onready var pivot: SpringArm3D = get_parent()
@onready var linedraw:Node2D = $Node2D

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
	
	pivot_speed.y = lerpf(pivot_speed.y, 0, pivot_damp * delta)
	pivot_speed.x = lerpf(pivot_speed.x, 0, pivot_damp * delta)
	pivot.rotation.y += pivot_speed.y
	pivot.rotation.x = clampf(pivot.rotation.x - pivot_speed.x, deg_to_rad(-55), deg_to_rad(-5))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("grab"):
		try_grab()
		print("im eppy")
	elif Input.is_action_just_released("grab"):
		grabbed_object = null

	if grabbed_object:
		var ray = get_ray()
		var origin = ray.origin
		var direction = ray.direction
		
		
		var target = origin + direction * grab_distance_dynamic

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(origin, target)
		query.collision_mask = 4

		var target_pos: Vector3
		var result = space_state.intersect_ray(query)
		if result and result.has("position"):
			target_pos = result["position"]
			print("hi")
		else:
			target_pos = target  # fallback

		var to_target = target_pos - grabbed_object.global_position
		var force = to_target.normalized() * (spring_strength * to_target.length()) - grabbed_object.linear_velocity * damping

		grabbed_object.apply_central_force(force)



func _input(event: InputEvent) -> void:
	# Toggle mouse mode
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Rotate camera pivot with mouse
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		pivot_speed.y += -event.relative.x * mouse_sensitivity.x
		pivot_speed.x += -event.relative.y * mouse_sensitivity.y
		#rotation.x = clamp(rotation.x, deg_to_rad(-45), deg_to_rad(0))


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
	if grabbed_object is Kerfzel:
		grabbed_object._on_timer_timeout()


func get_ray() -> Dictionary[StringName, Vector3]:
	var mouse_pos := get_viewport().get_mouse_position()
	var origin := project_ray_origin(mouse_pos)
	var direction := project_ray_normal(mouse_pos)
	return {
		&"origin": origin,
		&"direction": direction
	} as Dictionary[StringName, Vector3]


#func get_ray_target_position() -> Vector3:
	#var ray = get_ray()
	#return ray.origin + ray.direction * grab_distance_dynamic
