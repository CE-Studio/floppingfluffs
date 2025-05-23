class_name Kerfzel
extends RigidBody3D


enum FurPattern {
	NONE,
	SWIRLY,
}


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
@export_range(1, 2) var eyes:int = 1
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


func _recur_mat(n:Node) -> void:
	if n is MeshInstance3D:
		n.material_override = mat
	for i in n.get_children():
		_recur_mat(i)


func _physics_process(delta: float) -> void:
	if position.y < -10:
		newpos = Vector3(0, 10, 0)


func _integrate_forces(state:PhysicsDirectBodyState3D) -> void:
	if newpos != null:
		state.linear_velocity = Vector3.ZERO
		var t := state.get_transform()
		t.origin = newpos
		global_position = newpos
		state.transform = t
		newpos = null


func _on_timer_timeout() -> void:
	apply_central_impulse(Vector3.UP * 3)
	for i in headobjs:
		i.speak()
	if randf_range(0, 10) > 9:
		$Timer.start(randf_range(20, 120))
	else:
		$Timer.start(randf_range(0.5, 2))
