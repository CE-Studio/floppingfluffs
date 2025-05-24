extends MarginContainer


var tracking:Node3D


@onready var point:Node3D = $Infohud/point
@onready var statlist:VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2
@onready var kname:Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/name
@onready var kobj:Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/objective

@onready var spinnerspeed: VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer3
@onready var h_slider: HSlider = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer3/MarginContainer/HSlider

func  _process(delta: float) -> void:
	if is_instance_valid(tracking):
		point.global_position = tracking.global_position
		point.scale = tracking.scale
		var parent_decoration := tracking.get_parent_node_3d()
		if parent_decoration and parent_decoration is StaticDecoration:
			spinnerspeed.show()
			parent_decoration.set_speed(h_slider.value)
		else:
			spinnerspeed.hide()
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
