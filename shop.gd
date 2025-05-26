extends HBoxContainer


const blank:PackedScene = preload("res://ui/shop_button.tscn")


@export var items:Array[ShopItem] = []


func _ready() -> void:
	for i in items:
		if not is_instance_valid(i):
			continue
		var a:ShopButton = blank.instantiate()
		a.setup(i.item, i.price)
		add_child(a)
