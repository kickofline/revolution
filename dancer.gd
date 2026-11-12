class_name RhythmDancer
extends Node2D


const LANE_KEYS: Array[String] = ["left", "up", "right"]
const POSE_TIME: float = 0.22
const MISS_TINT: Color = Color(1.0, 0.4, 0.4, 1.0)

@onready var sprite: Sprite2D = $Sprite

var _data: Dictionary = {}
var _idle_frames: Array[Texture2D] = []
var _idle_index: int = 0
var _idle_flipped: bool = false
var _pose_left: float = 0.0
var _base_scale: Vector2 = Vector2.ONE
var _move_tween: Tween
var _tint_tween: Tween


func _ready() -> void:
	_base_scale = sprite.scale


func set_character(data: Dictionary) -> void:
	_data = data
	_idle_frames = _build_idle_frames(data)
	reset()


func reset() -> void:
	_kill_tweens()
	_pose_left = 0.0
	_idle_index = 0
	_idle_flipped = false
	sprite.scale = _base_scale
	sprite.position = Vector2.ZERO
	sprite.modulate = Color.WHITE
	_show_idle()


func on_beat() -> void:
	# pose until it finish, then go back to  idle
	if _pose_left > 0.0 or _idle_frames.is_empty():
		return
	_idle_index = (_idle_index + 1) % _idle_frames.size()
	if bool(_data.get("flip_idle", false)):
		_idle_flipped = not _idle_flipped
	_show_idle()
	_bounce(0.06, 0.0, 0.14)


func pose(lane: int) -> void:
	if lane < 0 or lane >= LANE_KEYS.size():
		return
	var key: String = LANE_KEYS[lane]
	if not _data.has(key):
		# Characters without poses just hop.
		_bounce(0.10, 10.0, 0.16)
		return
	var flip: bool = lane == 0 and bool(_data.get("flip_left", false))
	_show(_data[key] as Texture2D, flip)
	_pose_left = POSE_TIME
	_bounce(0.10, 6.0, 0.14)


func stumble() -> void:
	if _data.has("miss"):
		_show(_data["miss"] as Texture2D, false)
		_pose_left = POSE_TIME * 1.5
	_bounce(-0.08, 0.0, 0.2)
	if _tint_tween != null and _tint_tween.is_valid():
		_tint_tween.kill()
	sprite.modulate = MISS_TINT
	_tint_tween = create_tween()
	_tint_tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)



func _process(delta: float) -> void:
	if _pose_left <= 0.0:
		return
	_pose_left -= delta
	if _pose_left <= 0.0:
		_show_idle()


func _show_idle() -> void:
	if _idle_frames.is_empty():
		return
	_show(_idle_frames[_idle_index], _idle_flipped)


func _show(texture: Texture2D, flip: bool) -> void:
	if texture == null:
		return
	sprite.texture = texture
	sprite.flip_h = flip
	# Put this node's origin at the character's feet so squash
	# and stretch keep the feet planted on the floor.
	sprite.offset = Vector2(0.0, -texture.get_height() * 0.5)


func _bounce(stretch: float, hop: float, duration: float) -> void:
	if _move_tween != null and _move_tween.is_valid():
		_move_tween.kill()
	# Positive stretch = tall and thin; negative = squashed.
	sprite.scale = _base_scale * Vector2(1.0 - stretch * 0.5, 1.0 + stretch)
	sprite.position = Vector2(0.0, -hop)
	_move_tween = create_tween().set_parallel(true)
	_move_tween.tween_property(sprite, "scale", _base_scale, duration) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_move_tween.tween_property(sprite, "position", Vector2.ZERO, duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _kill_tweens() -> void:
	if _move_tween != null and _move_tween.is_valid():
		_move_tween.kill()
	if _tint_tween != null and _tint_tween.is_valid():
		_tint_tween.kill()


func _build_idle_frames(data: Dictionary) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	if data.has("sheet"):
		# sprite shee
		var sheet: Texture2D = data["sheet"] as Texture2D
		var columns: int = int(data.get("hframes", 1))
		var rows: int = int(data.get("vframes", 1))
		var count: int = int(data.get("frame_count", columns * rows))
		var cell: Vector2 = Vector2(sheet.get_size()) / Vector2(columns, rows)
		for i in range(count):
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = sheet
			var column: int = i % columns
			var row: int = floori(i / float(columns))
			atlas.region = Rect2(Vector2(column, row) * cell, cell)
			frames.append(atlas)
	else:
		for texture in data.get("idle", []):
			frames.append(texture as Texture2D)
	return frames
