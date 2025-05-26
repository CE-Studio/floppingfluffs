class_name Toy
extends RigidBody3D


@export var tname := "Toy..?"
@export_multiline var tdesc := "What... What is this???"


@onready var bonk:AudioStreamPlayer3D = AudioStreamPlayer3D.new()


var newpos:
	set(val):
		if val is Vector3:
			newpos = val
		if val == null:
			newpos = val


func _ready() -> void:
	add_to_group("toys")
	add_child(bonk)
	bonk.stream = preload("res://sound/impactrandom.tres")
	bonk.bus = &"Sfx"
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(bonksound)


func bonksound(_b:Node) -> void:
	if linear_velocity.length() > 0.8:
		bonk.play()


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
