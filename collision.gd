class_name Toy
extends RigidBody3D


var newpos:
	set(val):
		if val is Vector3:
			newpos = val
		if val == null:
			newpos = val


func _ready() -> void:
	add_to_group("toys")


func _integrate_forces(state:PhysicsDirectBodyState3D) -> void:
	if newpos != null:
		state.linear_velocity = Vector3.ZERO
		var t := state.get_transform()
		t.origin = newpos
		global_position = newpos
		state.transform = t
		newpos = null


func _process(delta: float) -> void:
	if position.y < -10:
		newpos = Vector3(0, 10, 0)
