class_name Kerfzel
extends RigidBody3D


const FurPattern = [
	preload("res://textures/decals/none.png"),
	preload("res://textures/decals/swirly.png"),
	preload("res://textures/decals/fuffy.png"),
	preload("res://textures/decals/fyrfy.png"),
	preload("res://textures/decals/polar.png"),
	preload("res://textures/decals/stripes.png"),
]


const GEM:PackedScene = preload("res://parts/gem.tscn")


const SAVE_BASE = {
	"colo": [0.8, 0.8, 0.8],
	"posi": [0, 10, 0],
	"patt": 0,
	"eyes": 1,
	"ears": 2,
	"tail": 2,
	"head": 1,
	"arms": 1,
	"legs": 1,
	"nost": 1,
	"size": 1.0,
	"happ": 0.0,
	"name": "Name me!",
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


var petting := 0.0


@export var mat:StandardMaterial3D = StandardMaterial3D.new()
@export var fur_pattern:int = 0
@export_range(1, 2) var eyes:int = 1
@export_range(1, 3) var ears:int = 2
@export_range(1, 3) var tails:int = 2
@export_range(1, 3) var heads:int = 1
@export_range(1, 2) var arms:int = 1
@export_range(1, 2) var legs:int = 1
@export_range(1, 3) var nostrils:int = 1
@export_range(0.8, 2.0) var size:float = 1
@export var happi := 0.0
@export var kname:String = "Name meeeee!"
@export var rando := false


var newpos:
	set(val):
		if val is Vector3:
			newpos = val
		if val == null:
			newpos = val


func get_save() -> Dictionary:
	var col = mat.albedo_color
	return {
		"colo": [col.r, col.g, col.b],
		"posi": [global_position.x, global_position.y, global_position.z],
		"patt": fur_pattern,
		"eyes": eyes,
		"ears": ears,
		"tail": tails,
		"head": heads,
		"arms": arms,
		"legs": legs,
		"nost": nostrils,
		"size": size,
		"happ": happi,
		"name": kname,
	}


func set_save(dat:Dictionary) -> void:
	dat = dat.duplicate(true)
	dat.merge(SAVE_BASE)
	var col = Color()
	var pos := Vector3()
	col.r = dat.colo[0]; col.g = dat.colo[1]; col.b = dat.colo[2]
	pos.x = dat.posi[0]; pos.y = dat.posi[1]; pos.z = dat.posi[2]
	newpos = pos
	fur_pattern = dat.patt
	ears = dat.ears
	tails = dat.tail
	heads = dat.head
	arms = dat.arms
	legs = dat.legs
	nostrils = dat.nost
	size = dat.size
	happi = dat.happ
	kname = dat.name
	eyes = dat.eyes
	upd()


func _ready() -> void:
	$AudioStreamPlayer3D.pitch_scale = 1.2
	_recur_mat(self)
	if kname == "Name meeeee!":
		kname = NameGen.gen()
	if rando:
		size = randf_range(0.8, 2.0)
		mat.albedo_color = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
		heads = randi_range(1, 3)
		arms = randi_range(1, 2)
		legs = randi_range(1, 2)
		tails = randi_range(2, 3)
		nostrils = randi_range(1, 3)
		fur_pattern = randi_range(0, FurPattern.size() - 1)
		ears = randi_range(1, 3)
		eyes = randi_range(1, 2)
	upd()


func upd() -> void:
	$Decal.texture_albedo = FurPattern[fur_pattern]
	scale = Vector3.ONE * size
	$kerfbody.heads = heads
	$kerfbody.arms = arms
	$kerfpelvis.legs = legs
	$kerfpelvis.tails = tails
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
	if happi > 10:
		happi -= 10
		var a = GEM.instantiate()
		ToyLayer.instance.add_child(a)
		a.global_position = global_position + Vector3(0, 10, 0)
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
			if targobj == self:
				_on_timer_2_timeout()
				return
			if not is_instance_valid(targobj):
				_on_timer_2_timeout()
				return
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
		ch.append_array(ToyLayer.instance.get_children())
		targobj = ch.pick_random()
		if state == State.SHMOOVIN:
			$Timer2.start(randf_range(0.5, 10))
		direction = randf_range(-PI, PI)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(&"toys"):
		happi += 0.5
		if body is RigidBody3D:
			var push := transform.basis * Vector3.FORWARD
			push.y += 1
			body.apply_central_impulse(push * 3.0)
	if body is Kerfzel:
		_on_timer_timeout()
		happi += 1


func _process(delta: float) -> void:
	petting = move_toward(petting, 0, delta)
	if petting > 0.5:
		happi += delta / 2.0
	$AudioStreamPlayer3D2.volume_db = remap(petting, 0, 3, -80, 0)


func pet() -> void:
	PlayerCam.instance.hearts.emitting = true
	petting = 3


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if PlayerCam.pettin:
		if event is InputEventMouseMotion:
			if Input.is_action_pressed("grab"):
				pet()
