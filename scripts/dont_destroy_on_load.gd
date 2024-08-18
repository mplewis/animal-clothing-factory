extends Node2D

class_name dont_destroy_on_load

var container : HBoxContainer
var last_game_animals : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func layout_animals(container : HBoxContainer):
	
	#var screenWidth = get_viewport_rect().size.x
	#var screenHeight = get_viewport_rect().size.y
	#container.set_size(Vector2(screenWidth, 800))
	#container.position.y = screenHeight - 200
	#container.position.x = 300

	for animal : Animal in last_game_animals.get_children():
		animal.show()
		
		var control := Control.new()
		animal.reparent(control)
		animal.position = Vector2(250, 500) #assuming that all animals are 500x500 big idk
		control.size_flags_horizontal |= Control.SIZE_EXPAND
		control.custom_minimum_size = Vector2(200,200)
		container.add_child(control)
		animal.play_dance()


func clear_animals() -> void :
	remove_child(container)
	container = null
