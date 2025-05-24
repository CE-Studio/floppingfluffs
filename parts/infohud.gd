extends MarginContainer


var tracking:Node3D


@onready var point:Node3D = $Infohud/point
@onready var statlist:VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2
@onready var kname:Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/name
@onready var kobj:Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/objective

@onready var spinnerspeed: VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer3
@onready var h_slider: HSlider = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer3/MarginContainer/HSlider
@onready var button: Button = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer3/MarginContainer2/Button


@onready var toything:VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer4
@onready var toyname:Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer4/objname
@onready var toydesc:Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer4/MarginContainer/desc


func _ready() -> void:
	h_slider.value_changed.connect(set_dec_speed)
	button.pressed.connect(pickup_dec)
	
func  _physics_process(delta: float) -> void:
	if is_instance_valid(tracking):
		point.global_position = tracking.global_position
		point.scale = tracking.scale
		var parent_decoration := tracking.get_parent_node_3d()
		if parent_decoration and parent_decoration is StaticDecoration:
			spinnerspeed.show()
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
		if tracking is Toy:
			toything.show()
			toyname.text = tracking.tname
			toydesc.text = tracking.tdesc
		else:
			toything.hide()
	else:
		statlist.hide()


func set_dec_speed(value: float):
	var parent_decoration := tracking.get_parent_node_3d()
	if parent_decoration and parent_decoration is StaticDecoration:
		parent_decoration.set_speed(value)
		
func pickup_dec():
	var parent_decoration := tracking.get_parent_node_3d()
	if parent_decoration and parent_decoration is StaticDecoration:
		parent_decoration.pickup()
