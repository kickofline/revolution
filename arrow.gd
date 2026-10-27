class_name RhythmNote
extends Node2D

const TEXTURES = [
	preload("res://assets/kenney_cursor-pixel-pack/Tiles/tile_0073.png"),
	preload("res://assets/kenney_cursor-pixel-pack/Tiles/tile_0070.png"),
	preload("res://assets/kenney_cursor-pixel-pack/Tiles/tile_0072.png")
]

var lane: int = 0
var hit_time: float = 0.0

@onready var visual: Sprite2D = $Visual


func setup(new_lane: int, new_hit_time: float) -> void:
	lane = new_lane
	hit_time = new_hit_time
	visual.texture = TEXTURES[lane]
