extends Node

class_name ObjectCreator

@export var PossibleAnimals : Array[PackedScene]
@export var PossibleClothing : Array[PackedScene]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var animal = self.create_random_animal()
	#animal.position.x = 500
	#animal.position.y = 500
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_random_animal() -> Animal :

	var animalScene = PossibleAnimals.pick_random()
	var instantiatedAnimal = animalScene.instantiate()
	add_child(instantiatedAnimal)
	return instantiatedAnimal

func create_random_clothing() -> Node2D :
	var clothingScene = PossibleClothing.pick_random()
	var instantiatedClothing = clothingScene.instantiate()
	add_child(instantiatedClothing)
	return instantiatedClothing
