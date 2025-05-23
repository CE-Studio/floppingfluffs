class_name Kerfzel
extends RigidBody3D


enum FurPattern {
	NONE,
	SWIRLY,
}


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


func _ready() -> void:
	_recur_mat(self)


func _recur_mat(n:Node) -> void:
	if n is MeshInstance3D:
		n.material_override = mat
	for i in n.get_children():
		_recur_mat(i)
