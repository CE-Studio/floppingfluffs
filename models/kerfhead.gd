class_name KerfHead
extends Node3D


@export var ears:int = 2:
	set(value):
		ears = value
		_upd()
@export var eyes:int = 1:
	set(value):
		eyes = value
		_upd()

func _ready() -> void:
	_upd()


func _random_blink() -> void:
	$AnimationPlayer2.speed_scale = randf_range(0.1, 3)


func _upd() -> void:
	match ears:
		1:
			$Armature_002/Skeleton3D/BoneAttachment3D/earsl/ear2l.hide()
			$Armature_002/Skeleton3D/BoneAttachment3D/earsl/ear3l.hide()
			$Armature_002/Skeleton3D/BoneAttachment3D/earsr/ear2r.hide()
			$Armature_002/Skeleton3D/BoneAttachment3D/earsr/ear3r.hide()
		2:
			$Armature_002/Skeleton3D/BoneAttachment3D/earsl/ear3l.hide()
			$Armature_002/Skeleton3D/BoneAttachment3D/earsr/ear3r.hide()
			$Armature_002/Skeleton3D/BoneAttachment3D/earsl/ear2l.show()
			$Armature_002/Skeleton3D/BoneAttachment3D/earsr/ear2r.show()
		3:
			$Armature_002/Skeleton3D/BoneAttachment3D/earsl/ear3l.show()
			$Armature_002/Skeleton3D/BoneAttachment3D/earsr/ear3r.show()
			$Armature_002/Skeleton3D/BoneAttachment3D/earsl/ear2l.show()
			$Armature_002/Skeleton3D/BoneAttachment3D/earsr/ear2r.show()
	$AnimationPlayer2.play("blink" + str(eyes))


func speak():
	$AnimationPlayer.play("speak")


func disable() -> void:
	hide()
	$Armature_002/Skeleton3D/SpringBoneSimulator3D.active = false


func enable() -> void:
	show()
	$Armature_002/Skeleton3D/SpringBoneSimulator3D.active = true
