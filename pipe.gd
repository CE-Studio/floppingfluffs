extends Node3D

@onready var path: Path3D = $Path3D
@onready var entrance: Area3D = $Entrance
@onready var exit: Area3D = $Exit
@onready var entrance_placer: PathFollow3D = $Path3D/EntrancePlacer

@export var tube_speed: float = 10.0
@export var curve: Curve3D


enum TravelDirection {
	FORWARD = 1,
	BACKWARD = -1
}

func _ready() -> void:
	entrance.body_entered.connect(_on_body_entered.bind(TravelDirection.FORWARD))
	exit.body_entered.connect(_on_body_entered.bind(TravelDirection.BACKWARD))

	##Position entrance and exit at the start and end of the path
	entrance_placer.progress_ratio = 0
	entrance.global_transform = entrance_placer.global_transform


	entrance_placer.progress_ratio = 1
	exit.global_transform = entrance_placer.global_transform
	

func _on_body_entered(body: Node3D, direction: TravelDirection) -> void:
	if not body is RigidBody3D:
		return
	if direction == TravelDirection.FORWARD:
		body.global_position += entrance.global_basis.z
	else: 	
		body.global_position += exit.global_basis.z
	var tube_follower := TubeFollow.new()
	path.add_child(tube_follower)
	tube_follower.Finished.connect(pop_out)
	tube_follower.init(body, direction, tube_speed)

func pop_out(body: RigidBody3D, direction: TravelDirection):
	if direction == TravelDirection.FORWARD:
		body.global_position -= exit.global_basis.z
	else: 	
		body.global_position -= entrance.global_basis.z
class TubeFollow:
	extends PathFollow3D

	var target: RigidBody3D
	var direction: int = 1
	var speed: float = 10.0
	var done: bool = false

	signal Finished(body:RigidBody3D, direction: TravelDirection)
	func init(p_target: RigidBody3D, p_direction: int, p_speed: float) -> void:
		target = p_target
		target.set_collision_layer_value(2, false)
		direction = p_direction
		speed = p_speed
		progress_ratio = 0.0 if direction == TravelDirection.FORWARD else 1.0
		
		set_physics_process(true)

	func _physics_process(delta: float) -> void:
		if done or target == null:
			queue_free()
			return

		# Move along the path
		progress += speed * direction * delta

		# Apply force toward the current follower position
		var direction_vector = (global_position - target.global_position).normalized()
		var dist = global_position.distance_to(target.global_position)
		target.apply_central_force(direction_vector * speed * dist * 5.0)

		# Completion check with tolerance
		if (direction == 1 and progress_ratio >= 0.99) or (direction == -1 and progress_ratio <= 0.01):
			set_physics_process(false)
			print("im workin on it")
			get_tree().create_timer(1).timeout.connect(func(): target.set_collision_layer_value(2, true))
			Finished.emit(target, direction)
			done = true
		
