extends Node3D


@export var heads := 1:
	set(value):
		heads = value
		_upd()


func _ready() -> void:
	_upd()


func _upd() -> void:
	match heads:
		1:
			$Armature/Skeleton3D/BoneAttachment3D/heads/head1/kerfhead.enable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head2/kerfhead.disable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head2/kerfhead2.disable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head3/kerfhead.disable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head3/kerfhead2.disable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head3/kerfhead3.disable()
		2:
			$Armature/Skeleton3D/BoneAttachment3D/heads/head1/kerfhead.disable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head2/kerfhead.enable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head2/kerfhead2.enable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head3/kerfhead.disable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head3/kerfhead2.disable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head3/kerfhead3.disable()
		3:
			$Armature/Skeleton3D/BoneAttachment3D/heads/head1/kerfhead.disable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head2/kerfhead.disable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head2/kerfhead2.disable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head3/kerfhead.enable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head3/kerfhead2.enable()
			$Armature/Skeleton3D/BoneAttachment3D/heads/head3/kerfhead3.enable()
