extends Node2D

class_name Animal


@export var anchor_base : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#self.attach_clothing(testTie)
	#self.attach_clothing(testShirt)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#returns the difference in scale from the desired scale
func attach_clothing(clothing_item : Node2D ) -> float:
	var result = 0.0
	print("trying to get " + clothing_item.name + "Anchor")
	var anchorNode = anchor_base.get_node(NodePath(clothing_item.name + "Anchor"))
	if(anchorNode != null):
		clothing_item.reparent(self)
		#tweens go one after the other if you put them in one, so create 2 separate ones so that they happen together.
		var locTween = clothing_item.create_tween()
		locTween.tween_property(clothing_item, "position", anchorNode.position, .2)
		var rotTween = clothing_item.create_tween() 
		rotTween.tween_property(clothing_item, "rotation", anchorNode.rotation, .2)
		

		var desiredScale = anchorNode.scale.x
		result = abs(desiredScale - clothing_item.scale.x)
	else:
		print("No anchor for clothing " + clothing_item.name)

	return result

func get_target_scale_for_clothing(clothingName : String) -> float:
	var anchorNode = anchor_base.get_node(NodePath(clothingName + "Anchor"))
	return anchorNode.scale.x
	
