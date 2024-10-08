class_name Animal
extends Node2D

## The clothing scenes that this animal supports
@export var PossibleClothing: Array[PackedScene]

@export var anchor_base: Node2D
@export var animation_player: AnimationPlayer
@export var possible_colors: Array[Color] = []

const TWEEN_DURATION_SEC = 0.3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if material is ShaderMaterial and possible_colors.size() > 0:
		material = material.duplicate()
		var inner_color: Color = possible_colors.pick_random()
		var lineart_color := inner_color.darkened(0.5)
		(material as ShaderMaterial).set_shader_parameter("light_color", inner_color)
		(material as ShaderMaterial).set_shader_parameter("dark_color", lineart_color)


func _to_string():
	return "<Animal %s>" % self.name


## Attach a piece of clothing to an animal. Returns the difference in scale from the desired scale.
func attach_clothing(clothing_item: Clothing) -> SizeResult:
	var anchor_node = get_clothing_anchor(clothing_item.name)

	# Make the clothing item red
	clothing_item.sprite.modulate = Color(1, 0, 0)

	var result = SizeResult.new()
	result.expected_size = expected_clothing_width_px(clothing_item.name)
	result.actual_size = clothing_item.width_px()

	clothing_item.reparent(self)

	# Create two separate tweens so that they run in parallel
	var loc_tween = clothing_item.create_tween()
	loc_tween.tween_property(clothing_item, "position", anchor_node.position, TWEEN_DURATION_SEC)
	var rot_tween = clothing_item.create_tween()
	rot_tween.tween_property(clothing_item, "rotation", anchor_node.rotation, TWEEN_DURATION_SEC)

	return result


func get_clothing_anchor(clothing_name: String) -> Sprite2D:
	var node = anchor_base.get_node(NodePath(clothing_name + "Anchor"))
	assert(node, "No anchor for clothing %s" % clothing_name)
	return node


## Returns this animal's desired width (px) for a given piece of clothing
func expected_clothing_width_px(clothing_name: String) -> int:
	var anchor_node := get_clothing_anchor(clothing_name)
	return int(
		anchor_node.texture.get_width() * anchor_node.scale.x * anchor_base.scale.x * self.scale.x
	)


func play_dance() -> void:
	animation_player.play("animal_animations/animal_dance")
