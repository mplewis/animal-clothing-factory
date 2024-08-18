extends Node2D

class_name dont_destroy_on_load

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func layout_animals(animalParentNode : Node2D):
	var container := HBoxContainer.new()

	add_child(container)
	
	var screenWidth = get_viewport_rect().size.x
	var screenHeight = get_viewport_rect().size.y
	container.set_size(Vector2(screenWidth, 800))
	container.position.y = screenHeight - 500
	
	
	for animal : Animal in animalParentNode.get_children():
		animal.show()
		
		var control := Control.new()
		animal.reparent(control)
		animal.position = Vector2.ZERO
		control.size_flags_horizontal |= Control.SIZE_EXPAND
		container.add_child(control)
		animal.play_dance()
		
