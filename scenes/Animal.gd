extends Node2D

class_name Animal


@export var anchor_base : Node2D

@export var testTie: Node2D
@export var testShirt: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.attach_clothing(testTie)
	self.attach_clothing(testShirt)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_key_pressed(KEY_T)):
		pass

#returns the difference in scale from the desired scale
func attach_clothing(clothing_item : Node2D ) -> float:
	var result = 0.0
	var anchorNode = anchor_base.get_node(NodePath(clothing_item.name + "Anchor"))
	if(anchorNode != null):
		clothing_item.reparent(self)
		var tween = clothing_item.create_tween()
		tween.tween_property(clothing_item, "position", anchorNode.position, .4)
		tween.tween_property(clothing_item, "rotation", anchorNode.rotation, .4)

		var desiredScale = anchorNode.scale.x
		result = abs(desiredScale - clothing_item.scale.x)
	else:
		print("No anchor for clothing " + clothing_item.name)

	return result

func get_target_scale_for_clothing(clothingName : String) -> float:
	var anchorNode = get_node(NodePath(clothingName))
	return anchorNode.scale.x
	
