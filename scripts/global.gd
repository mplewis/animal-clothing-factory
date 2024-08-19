extends Node

## The player's current score
var score := 0


## Print a dictionary of a bunch of named items for debugging.
func print_many(desc: String, items: Dictionary) -> void:
	print("%s:" % desc)
	for key in items.keys():
		print("    %s: %s" % [key, items[key]])
