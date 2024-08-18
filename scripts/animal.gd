class_name Animal
extends Node2D

@export var anchor_base: Node2D
@export var animation_player: AnimationPlayer

const TWEEN_POSITION_DURATION_SEC = 0.3
const TWEEN_ROTATION_DURATION_SEC = 0.3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#self.play_dance()
	pass
	#self.attach_clothing(testTie)
	#self.attach_clothing(testShirt)


func _process(_delta: float) -> void:
	pass


## Attach a piece of clothing to an animal. Returns the difference in scale from the desired scale.
func attach_clothing(clothing_item: Node2D) -> float:
	var anchor_node = anchor_base.get_node(NodePath(clothing_item.name + "Anchor"))

	if !anchor_node:
		print("No anchor for clothing " + clothing_item.name)
		return 0.0

	clothing_item.reparent(self)

	# tweens go one after the other if you put them in one, so create 2 separate ones so that they happen together.
	var loc_tween = clothing_item.create_tween()
	loc_tween.tween_property(
		clothing_item, "position", anchor_node.position, TWEEN_POSITION_DURATION_SEC
	)
	var rot_tween = clothing_item.create_tween()
	rot_tween.tween_property(
		clothing_item, "rotation", anchor_node.rotation, TWEEN_ROTATION_DURATION_SEC
	)

	var desired_scale = anchor_node.scale.x
	return abs(desired_scale - clothing_item.scale.x)


func get_target_scale_for_clothing(clothing_name: String) -> float:
	var node_path = clothing_name + "Anchor"
	var node = anchor_base.get_node(NodePath(node_path))
	var node_scale = node.scale.x
	print("Scale for %s is %s" % [clothing_name, node_scale])
	return node_scale


func play_dance() -> void:
	animation_player.play("animal_animations/animal_dance")
