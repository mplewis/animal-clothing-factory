extends Node2D

class_name Animal

@export var anchor_base: Node2D
@export var animation_player: AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.play_dance()
	pass
	#self.attach_clothing(testTie)
	#self.attach_clothing(testShirt)


func _process(_delta: float) -> void:
	pass


#returns the difference in scale from the desired scale
func attach_clothing(clothing_item: Node2D) -> float:
	var result = 0.0
	var anchorNode = anchor_base.get_node(NodePath(clothing_item.name + "Anchor"))
	if anchorNode != null:
		clothing_item.reparent(self)
		# tweens go one after the other if you put them in one, so create 2 separate ones so that they happen together.
		var locTween = clothing_item.create_tween()
		locTween.tween_property(clothing_item, "position", anchorNode.position, .2)
		var rotTween = clothing_item.create_tween()
		rotTween.tween_property(clothing_item, "rotation", anchorNode.rotation, .2)

		var desiredScale = anchorNode.scale.x
		result = abs(desiredScale - clothing_item.scale.x)
	else:
		print("No anchor for clothing " + clothing_item.name)

	return result


func get_target_scale_for_clothing(clothing_name: String) -> float:
	var node_path = clothing_name + "Anchor"
	var node = anchor_base.get_node(NodePath(node_path))
	var node_scale = node.scale.x
	print("Scale for %s is %s" % [clothing_name, node_scale])
	return node_scale


func play_dance() -> void:
	var randSpeed = randf_range(.8, 1.2)
	animation_player.set_speed_scale(randSpeed)
	animation_player.play("animal_animations/animal_dance")
