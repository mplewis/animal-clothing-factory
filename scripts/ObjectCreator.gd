extends Node

class_name ObjectCreator

## The animals that this instance can create
@export var PossibleAnimals: Array[PackedScene]
## The clothing that this instance can create
@export var PossibleClothing: Array[PackedScene]


func _ready() -> void:
	# var animal = self.create_random_animal()
	# animal.position.x = 500
	# animal.position.y = 500
	pass  # Replace with function body.


func _process(_delta: float) -> void:
	pass


func create_random_animal() -> Animal:
	var animalScene = PossibleAnimals.pick_random()
	var instantiatedAnimal = animalScene.instantiate()
	add_child(instantiatedAnimal)
	return instantiatedAnimal


func create_random_clothing() -> Node2D:
	var clothingScene = PossibleClothing.pick_random()
	var instantiatedClothing = clothingScene.instantiate()
	add_child(instantiatedClothing)
	print(instantiatedClothing)
	return instantiatedClothing
