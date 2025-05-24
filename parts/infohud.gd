extends MarginContainer


var tracking:Node3D


@onready var point:Node3D = $Infohud/point
@onready var statlist:VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2
@onready var kname:Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/name
@onready var kobj:Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/objective


func  _process(delta: float) -> void:
	if is_instance_valid(tracking):
		point.global_position = tracking.global_position
		point.scale = tracking.scale
		if tracking is Kerfzel:
			statlist.show()
			kname.text = tracking.kname
			match tracking.state:
				Kerfzel.State.WALKIN:
					kobj.text = "Wandering"
				Kerfzel.State.WAITIN:
					kobj.text = "Vibing"
				Kerfzel.State.SHMOOVIN:
					kobj.text = "Shmoovin'"
				Kerfzel.State.WALKIN2ZER0:
					kobj.text = "Walking to the middle"
				Kerfzel.State.WALKIN2OTHER:
					if tracking.targobj is Kerfzel:
						kobj.text = "Walking to " + tracking.targobj.kname
					else:
						kobj.text = "Walking to object"
		else:
			statlist.hide()
	else:
		statlist.hide()
