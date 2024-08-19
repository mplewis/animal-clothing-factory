extends Node2D

class_name dont_destroy_on_load

var container: HBoxContainer
var last_game_animals: Node2D


func layout_animals(container: HBoxContainer):
	#var screenWidth = get_viewport_rect().size.x
	#var screenHeight = get_viewport_rect().size.y
	#container.set_size(Vector2(screenWidth, 800))
	#container.position.y = screenHeight - 200
	#container.position.x = 300

	# TODO: Implement game over screen
	pass
	# for animal : Animal in last_game_animals.get_children():
	# 	animal.show()

	# 	var control := Control.new()
	# 	animal.reparent(control)
	# 	animal.position = Vector2(250, 500) #assuming that all animals are 500x500 big idk
	# 	control.size_flags_horizontal |= Control.SIZE_EXPAND
	# 	control.custom_minimum_size = Vector2(200,200)
	# 	container.add_child(control)
	# 	animal.play_dance()


func clear_animals() -> void:
	remove_child(container)
	container = null
