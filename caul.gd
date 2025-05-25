extends Node3D


@onready var cir:Decal = $Decal
@onready var anim:AnimationPlayer = $AnimationPlayer


var bodies:Array[Node] = []
var kerfs:Array[Kerfzel] = []


func _process(delta: float) -> void:
	cir.rotation.y += delta
	if not anim.is_playing():
		if kerfs.size() > 0:
			anim.play("new_animation")


func _physics_process(delta: float) -> void:
	for i in bodies:
		if i is RigidBody3D:
			i.apply_central_impulse(Vector3(1, 5, -1))


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is SoulSphere:
		create_kerf(body)
	else:
		bodies.append(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	while bodies.has(body):
		bodies.erase(body)


func create_kerf(sp:SoulSphere) -> void:
	var wacky := sp.wacky
	sp.queue_free()
	var k:Kerfzel = preload("res://parts/kerf.tscn").instantiate()
	kerfs.append(k)
	if wacky:
		k.rando = true
	else:
		k.size = randf_range(0.9, 1.2)
		k.mat.albedo_color = Color(randf_range(0.5, 1), randf_range(0.5, 1), randf_range(0.5, 1))
		k.heads = 1
		k.arms = 1
		k.legs = 1
		k.tails = 2
		k.nostrils = 1
		k.fur_pattern = randi_range(0, Kerfzel.FurPattern.size() - 1)
		k.ears = 2
		k.eyes = 1


func spawn() -> void:
	$GPUParticles3D.emitting = true
	for i in kerfs:
		KerfLayer.instance.add_child(i)
		i.global_position = global_position + Vector3(0, 3, 0)
	kerfs = []
