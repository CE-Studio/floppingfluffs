extends Camera3D
class_name PlayerCam

@export var mouse_sensitivity: Vector2 = Vector2(0.002, 0.001)
@export var pivot_damp: float = 6
@export var grab_distance: float = 100.0
@export var spring_strength: float = 100.0
@export var damping: float = 10.0

static var pettin := false
var pivot_speed: Vector2 = Vector2.ZERO
var grab_distance_dynamic: float
var grabbed_object: RigidBody3D = null
static var monies:int = 3:
	set(val):
		monies = val
		if is_instance_valid(instance):
			instance.monlbl.text = "$" + str(val)


@onready var pivot: SpringArm3D = get_parent()
@onready var linedraw: Node2D = $Node2D
@onready var grab:Button = $"../MarginContainer/VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/grab"
@onready var pet:Button = $"../MarginContainer/VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/pet"
@onready var hearts:GPUParticles2D = $GPUParticles2D
@onready var monlbl:Label = $"../MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/Label"

static var instance: PlayerCam

func _ready() -> void:
	instance = self
	DebugMenu.Register("Speed", func(): return pivot_speed)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
	hearts.position = get_viewport().get_mouse_position()
	if Input.is_action_just_released("zoom_in"):
		pivot.spring_length = clamp(pivot.spring_length - 0.5, 2.0, 20.0)
	elif Input.is_action_just_released("zoom_out"):
		pivot.spring_length = clamp(pivot.spring_length + 0.5, 2.0, 20.0)

	pivot_speed.y = lerpf(pivot_speed.y, 0, pivot_damp * delta)
	pivot_speed.x = lerpf(pivot_speed.x, 0, pivot_damp * delta)
	pivot.rotation.y += pivot_speed.y
	pivot.rotation.x = clampf(pivot.rotation.x - pivot_speed.x, deg_to_rad(-55), deg_to_rad(-5))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("grab"):
		if not try_grab():
			try_interact()
	elif Input.is_action_just_released("grab"):
		if grabbed_object:
			var parent_decoration := grabbed_object.get_parent_node_3d()
			if parent_decoration and parent_decoration is StaticDecoration:
				parent_decoration.place()
			grabbed_object = null

	if grabbed_object:
		var ray = get_ray()
		var origin = ray["origin"]
		var direction = ray["direction"]
		var target = origin + direction * grab_distance_dynamic

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(origin, target)
		query.collision_mask = 4  # Customizable for grab-while-held layer

		var result = space_state.intersect_ray(query)
		var target_pos: Vector3 = result.get("position", target)

		var to_target = target_pos - grabbed_object.global_position
		var force = to_target.normalized() * (spring_strength * to_target.length()) - grabbed_object.linear_velocity * damping
		grabbed_object.apply_central_force(force)

func _input(event: InputEvent) -> void:

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		pivot_speed.y += -event.relative.x * mouse_sensitivity.x
		pivot_speed.x += -event.relative.y * mouse_sensitivity.y

func try_grab() -> bool:
	if pettin:
		return false
	var ray = get_ray()
	var origin = ray["origin"]
	var direction = ray["direction"]
	var target = origin + direction * grab_distance

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, target)
	query.collision_mask = 3  # Layer for grabbable RigidBody3D

	var result = space_state.intersect_ray(query)
	if result and result.has("collider") and result["collider"] is RigidBody3D:
		if result["collider"] is Gem:
			result["collider"].queue_free()
			monies += 1
			return false
		grabbed_object = result["collider"]
		grab_distance_dynamic = (result["position"] - origin).length()
		InfoHud.tracking = grabbed_object

		if grabbed_object is Kerfzel:
			grabbed_object._on_timer_timeout()

		return true
	return false
	
func try_interact() -> void:
	var ray = get_ray()
	var origin = ray["origin"]
	var direction = ray["direction"]
	var target = origin + direction * grab_distance

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, target)
	query.collision_mask = 2  # Layer for interactable StaticBodies

	var result = space_state.intersect_ray(query)
	if result:
		var parent_decoration = result["collider"].get_parent_node_3d()
		print(parent_decoration)
		if parent_decoration and parent_decoration is StaticDecoration:
			InfoHud.tracking = result["collider"]

func get_ray() -> Dictionary[StringName, Vector3]:
	var mouse_pos := get_viewport().get_mouse_position()
	var origin := project_ray_origin(mouse_pos)
	var direction := project_ray_normal(mouse_pos)
	return {
		&"origin": origin,
		&"direction": direction
	}


func _on_grab_pressed() -> void:
	pettin = false
	grab.set_pressed_no_signal(true)
	pet.set_pressed_no_signal(false)


func _on_pet_pressed() -> void:
	pettin = true
	grab.set_pressed_no_signal(false)
	pet.set_pressed_no_signal(true)
