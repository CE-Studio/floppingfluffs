class_name ShopButton
extends Button


var price:int = 0
var texture:SceneTexture


func setup(tex:SceneTexture, pri:int) -> void:
	price = pri
	$PanelContainer/MarginContainer/Label.text = "$" + str(price)
	texture = tex
	icon = tex


func _process(delta: float) -> void:
	disabled = not PlayerCam.monies >= price


func _on_pressed() -> void:
	if PlayerCam.monies >= price:
		PlayerCam.monies -= price
		var a = texture.scene.instantiate()
		ToyLayer.instance.add_child(a)
		a.global_position = Vector3(0, 10, 0)
