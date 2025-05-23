class_name KerfPelvis
extends Node3D


@export var tails := 2:
	set(value):
		tails = value
		_upd()
@export var legs := 1:
	set(value):
		legs = value
		_upd()


func _upd() -> void:
	if legs > 1:
		$Armature_003/Skeleton3D/BoneAttachment3D/legs/kerflegl2.show()
		$Armature_003/Skeleton3D/BoneAttachment3D/legs/kerflegr2.show()
	else:
		$Armature_003/Skeleton3D/BoneAttachment3D/legs/kerflegl2.hide()
		$Armature_003/Skeleton3D/BoneAttachment3D/legs/kerflegr2.hide()
	match tails:
		1:
			$Armature_003/Skeleton3D/BoneAttachment3D/tails/kerftail.show()
			$Armature_003/Skeleton3D/BoneAttachment3D/tails/kerftail2.hide()
			$Armature_003/Skeleton3D/BoneAttachment3D/tails/kerftail3.hide()
		2:
			$Armature_003/Skeleton3D/BoneAttachment3D/tails/kerftail.hide()
			$Armature_003/Skeleton3D/BoneAttachment3D/tails/kerftail2.show()
			$Armature_003/Skeleton3D/BoneAttachment3D/tails/kerftail3.show()
		3:
			$Armature_003/Skeleton3D/BoneAttachment3D/tails/kerftail.show()
			$Armature_003/Skeleton3D/BoneAttachment3D/tails/kerftail2.show()
			$Armature_003/Skeleton3D/BoneAttachment3D/tails/kerftail3.show()
