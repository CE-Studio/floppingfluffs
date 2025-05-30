extends Camera3D
class_name PlayerCam

const HAND_CLOSED = preload("res://hand_closed.svg")
const HAND_OPEN = preload("res://hand_open.svg")
const HAND_POINT = preload("res://hand_point.svg")
const HAND_SPIN = preload("res://ui/rotate_ccw.svg")
const HAND_OFFSET = Vector2(8, 6)


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
var movement := Vector2.ZERO
var spring_length := 2.0
var in_menu := true

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
	$GPUParticles2D/Sprite2D.modulate.a = move_toward($GPUParticles2D/Sprite2D.modulate.a, 0, delta * 0.5)
	hearts.position = get_viewport().get_mouse_position()
	if not in_menu:
		if Input.is_action_just_released("zoom_in"):
			spring_length = clamp(spring_length - 0.5, 2.0, 20.0)
		elif Input.is_action_just_released("zoom_out"):
			spring_length = clamp(spring_length + 0.5, 2.0, 20.0)
	var minn := minf(pivot.spring_length, spring_length)
	var maxx := maxf(pivot.spring_length, spring_length)
	pivot.spring_length = clamp(lerpf(pivot.spring_length, spring_length, delta * 8.0), minn, maxx)
	pivot_speed.y = lerpf(pivot_speed.y, 0, pivot_damp * delta)
	pivot_speed.x = lerpf(pivot_speed.x, 0, pivot_damp * delta)
	pivot.rotation.y += pivot_speed.y
	pivot.rotation.x = clampf(pivot.rotation.x - pivot_speed.x, deg_to_rad(-55), deg_to_rad(-5))
	movearound(delta)


func _physics_process(delta: float) -> void:
	if in_menu:
		return
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
		Input.set_custom_mouse_cursor(HAND_CLOSED, 0, HAND_OFFSET)
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
	else:
		if pettin:
			Input.set_custom_mouse_cursor(HAND_OPEN, 0, HAND_OFFSET)
		else:
			Input.set_custom_mouse_cursor(HAND_POINT, 0, HAND_OFFSET)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_custom_mouse_cursor(HAND_SPIN, 0, HAND_OFFSET)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_unpause()
	if not in_menu:
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
		
		$GPUParticles2D/Sprite2D.modulate.a = 1

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


func movearound(delta:float) -> void:
	if in_menu:
		return
	var dist := Input.get_axis("closer", "further")
	dist *= delta
	dist *= 6.0
	grab_distance_dynamic += dist
	var wasd := Input.get_vector("left", "right", "forward", "backward")
	wasd = wasd.normalized() * 11.0
	movement = movement.move_toward(wasd, delta * 20)
	var acc := Vector3(movement.x, 0, movement.y)
	acc = pivot.global_basis * acc
	acc.y = 0
	pivot.global_position += acc * delta
	var d := pivot.global_position.length()
	d -= 20.0
	if d > 0:
		pivot.global_position = pivot.global_position.move_toward(Vector3.ZERO, d)


func _on_timer_timeout() -> void:
	if is_instance_valid(grabbed_object):
		$GPUParticles2D/Sprite2D.show()
		$AudioStreamPlayer.play()
	else:
		$GPUParticles2D/Sprite2D.hide()


func pause_unpause() -> void:
	in_menu = !in_menu
	Input.set_custom_mouse_cursor(HAND_POINT, 0, HAND_OFFSET)
	if in_menu:
		spring_length = 2.0
		$"../MarginContainer".hide()
		InfoHud.hide()
		$"../CenterContainer".show()
	else:
		spring_length = 12.0
		$"../MarginContainer".show()
		InfoHud.show()
		$"../CenterContainer".hide()


func _on_mastvol_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))


func _on_musvol_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))


func _on_sfxvol_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sfx"), linear_to_db(value))


func _on_check_box_toggled(toggled_on: bool) -> void:
	$"../../MultiMeshInstance3D" .visible = toggled_on
