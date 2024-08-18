extends Node

## The player's current score
var score := 0


func print_many(desc: String, items: Dictionary) -> void:
	print("%s:" % desc)
	for key in items.keys():
		print("    %s: %s" % [desc, items[key]])
