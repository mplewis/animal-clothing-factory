class_name Clothing
extends Node2D

@onready var sprite: Sprite2D = $Sprite


## The width of this item of clothing, in pixels, as displayed onscreen
func width_px() -> int:
	print("width: %d, scale: %d" % [sprite.texture.get_width(), self.scale.x])
	return int(sprite.texture.get_width() * self.scale.x)
