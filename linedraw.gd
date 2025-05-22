extends Node2D


@onready var pc:PlayerCam = $".."


func _process(delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if is_instance_valid(pc.grabbed_object):
		var eg := pc.grabbed_object.global_position
		var ogsp := get_viewport().get_mouse_position()
		var egsp := pc.unproject_position(eg)
		var cv := 1.0 - clampf((ogsp.distance_to(egsp) / 500) - 1, 0 ,1)
		draw_line(ogsp, egsp, Color(1.0, cv, cv), -1.0, true)
