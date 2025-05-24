class_name Kerfzel
extends RigidBody3D


enum FurPattern {
	NONE,
	SWIRLY,
}

var direction:float
enum State {
	WALKIN,
	WAITIN,
	SHMOOVIN,
	WALKIN2ZER0,
	WALKIN2OTHER,
}
var state:State = State.WAITIN
var targobj:Node3D


@onready var headobjs:Array[KerfHead] = [
	$kerfbody/Armature/Skeleton3D/BoneAttachment3D/heads/head1/kerfhead,
	$kerfbody/Armature/Skeleton3D/BoneAttachment3D/heads/head2/kerfhead,
	$kerfbody/Armature/Skeleton3D/BoneAttachment3D/heads/head2/kerfhead2,
	$kerfbody/Armature/Skeleton3D/BoneAttachment3D/heads/head3/kerfhead,
	$kerfbody/Armature/Skeleton3D/BoneAttachment3D/heads/head3/kerfhead2,
	$kerfbody/Armature/Skeleton3D/BoneAttachment3D/heads/head3/kerfhead3
]


@export var mat:Material = StandardMaterial3D.new()
@export var fur_pattern:FurPattern = FurPattern.NONE
@export_range(1, 2) var eyes:int = 1:
	set(val):
		eyes = val
		_upd()
@export_range(1, 3) var ears:int = 2
@export_range(1, 3) var tails:int = 2
@export_range(1, 3) var heads:int = 1
@export_range(1, 2) var arms:int = 1
@export_range(1, 2) var legs:int = 1
@export_range(1, 3) var nostrils:int = 1
@export_range(0.8, 2.0) var size:float = 1
@export var happi := 0.0


var newpos:
	set(val):
		if val is Vector3:
			newpos = val
		if val == null:
			newpos = val


func _ready() -> void:
	$AudioStreamPlayer3D.pitch_scale = 1.2
	_recur_mat(self)
	$kerfbody.heads = randi_range(1, 3)
	$kerfbody.arms = randi_range(1, 2)
	$kerfpelvis.legs = randi_range(1, 2)
	$kerfpelvis.tails = randi_range(2, 3)
	nostrils = randi_range(1, 3)
	ears = randi_range(1, 3)
	eyes = randi_range(1, 2)


func _upd() -> void:
	scale = Vector3.ONE * size
	for i in headobjs:
		i.eyes = eyes
		i.ears = ears
		i.nostrils = nostrils


func _recur_mat(n:Node) -> void:
	if n is MeshInstance3D:
		n.material_override = mat
	for i in n.get_children():
		_recur_mat(i)


func _physics_process(delta: float) -> void:
	if position.y < -10:
		newpos = Vector3(0, 10, 0)
	match state:
		State.WAITIN:
			pass
		State.WALKIN:
			if linear_velocity.length() < 1.0:
				apply_central_force(transform.basis * Vector3.FORWARD)
			var diff = wrapf(direction - rotation.y, -PI, PI)
			var dvel = diff * 2.0
			var ty = (dvel - angular_velocity.y) / 10.0
			apply_torque(Vector3(0, ty, 0))
		State.SHMOOVIN:
			apply_torque(Vector3(0, direction / 10.0, 0))
		State.WALKIN2ZER0:
			var posv2 = Vector2(global_position.x, -global_position.z)
			direction = wrapf(Vector2.ZERO.angle_to_point(posv2) + deg_to_rad(90), -PI, PI)
			if linear_velocity.length() < 1.0:
				apply_central_force(transform.basis * Vector3.FORWARD)
			var diff = wrapf(direction - rotation.y, -PI, PI)
			var dvel = diff * 2.0
			var ty = (dvel - angular_velocity.y) / 10.0
			apply_torque(Vector3(0, ty, 0))
		State.WALKIN2OTHER:
			var posv2 = Vector2(global_position.x, -global_position.z)
			var targv2 = Vector2(targobj.global_position.x, -targobj.global_position.z)
			direction = wrapf(targv2.angle_to_point(posv2) + deg_to_rad(90), -PI, PI)
			if linear_velocity.length() < 1.0:
				apply_central_force(transform.basis * Vector3.FORWARD)
			var diff = wrapf(direction - rotation.y, -PI, PI)
			var dvel = diff * 2.0
			var ty = (dvel - angular_velocity.y) / 10.0
			apply_torque(Vector3(0, ty, 0))


func _integrate_forces(state:PhysicsDirectBodyState3D) -> void:
	if newpos != null:
		state.linear_velocity = Vector3.ZERO
		var t := state.get_transform()
		t.origin = newpos
		global_position = newpos
		state.transform = t
		newpos = null


func _on_timer_timeout() -> void:
	$AudioStreamPlayer3D.play()
	apply_central_impulse(Vector3.UP * 3)
	for i in headobjs:
		i.speak()
	if randf_range(0, 10) > 9:
		$Timer.start(randf_range(20, 120))
	else:
		$Timer.start(randf_range(0.5, 2))


func _on_timer_2_timeout() -> void:
	$Timer2.start(randf_range(0.5, 120))
	if PlayerCam.instance.grabbed_object == self:
		state = State.WAITIN
	else:
		state = randi_range(0, State.size() - 1)
		#state = State.WALKIN2OTHER
		var ch = $"..".get_children()
		ch.append_array($"../../toys".get_children())
		targobj = ch.pick_random()
		if state == State.SHMOOVIN:
			$Timer2.start(randf_range(0.5, 10))
		direction = randf_range(-PI, PI)
