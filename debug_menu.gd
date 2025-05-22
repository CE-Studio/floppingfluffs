extends Control

@onready var container: VBoxContainer = $VBoxContainer


var watchers: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	for label in watchers.keys():
		var data = watchers[label]
		var text = data.get("getter").call()
		data.get("label_node").text = "%s: %s" % [label, text]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		visible = not visible
		get_viewport().set_input_as_handled()


func Register(label: String, getter: Callable) -> void:
	if watchers.has(label):
		return;
	var label_node: Label = Label.new()
	label_node.name = label
	label_node.text = "%s: ..." % label
	container.add_child(label_node)

	watchers[label] = {
		"getter": getter,
		"label_node": label_node
	}
	
