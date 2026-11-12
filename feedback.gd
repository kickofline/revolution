class_name RhythmFeedback
extends Node2D

const PERFECT_COLOR: Color = Color(1.0, 0.92, 0.30, 1.0)
const GOOD_COLOR: Color = Color(0.25, 0.85, 1.0, 1.0)
const MISS_COLOR: Color = Color(1.0, 0.22, 0.25, 1.0)

@onready var _targets: Array[Sprite2D] = [
	$"../Receptors/LeftTarget" as Sprite2D,
	$"../Receptors/UpTarget" as Sprite2D,
	$"../Receptors/RightTarget" as Sprite2D,
]

var _base_transforms: Array[Transform2D] = []
var _base_colors: Array[Color] = []
var _target_tweens: Array[Tween] = []
var _label_tweens: Array[Tween] = []
var _transients: Array[Node] = []


func _ready() -> void:
	for target in _targets:
		_base_transforms.append(target.transform)
		_base_colors.append(target.modulate)
		_target_tweens.append(null)


func play_hit(lane: int, perfect: bool, combo: int) -> void:
	if lane < 0 or lane >= _targets.size():
		return

	var color: Color = PERFECT_COLOR if perfect else GOOD_COLOR
	var punch_scale: float = 1.18 if perfect else 1.10
	var duration: float = 0.20 if perfect else 0.16
	_pulse_target(lane, color, punch_scale, duration)

	var center: Vector2 = to_local(_targets[lane].global_position)
	_spawn_label(center, perfect, combo, color)
	_spawn_sparks(center, perfect, color)


func play_miss(lane: int) -> void:
	if lane < 0 or lane >= _targets.size():
		return

	# A miss gets a red pulse, not a success label or particles.
	_pulse_target(lane, MISS_COLOR, 1.04, 0.14)


func reset() -> void:
	# Stop receptor animations before restoring their original appearance.
	for lane in range(_targets.size()):
		var tween: Tween = _target_tweens[lane]
		if tween != null and tween.is_valid():
			tween.kill()
		_restore_target(lane)

	# Label movement/fading is independent of the receptor animations.
	for tween in _label_tweens:
		if tween != null and tween.is_valid():
			tween.kill()
	_label_tweens.clear()

	# Do not erase from this array while iterating over it.
	for transient in _transients:
		if is_instance_valid(transient):
			if not transient.is_queued_for_deletion():
				transient.queue_free()
	_transients.clear()


func _pulse_target(
	lane: int,
	color: Color,
	punch_scale: float,
	duration: float
) -> void:
	var previous_tween: Tween = _target_tweens[lane]
	if previous_tween != null and previous_tween.is_valid():
		previous_tween.kill()

	# Always start from the saved original, never an unfinished pulse.
	_restore_target(lane)
	var target: Sprite2D = _targets[lane]
	var base_scale: Vector2 = target.scale
	target.modulate = color
	target.scale = base_scale * punch_scale

	var tween: Tween = create_tween()
	_target_tweens[lane] = tween
	tween.set_parallel(true)
	tween.tween_property(target, "scale", base_scale, duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "modulate", _base_colors[lane], duration)
	tween.chain().tween_callback(_restore_target.bind(lane))


func _restore_target(lane: int) -> void:
	_targets[lane].transform = _base_transforms[lane]
	_targets[lane].modulate = _base_colors[lane]
	_target_tweens[lane] = null


func _spawn_label(
	center: Vector2,
	perfect: bool,
	combo: int,
	color: Color
) -> void:
	var label: Label = Label.new()
	var judgment: String = "Perfect" if perfect else "Good"
	var font_size: int = 24 if perfect else 21
	label.text = "%s" % [judgment]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.size = Vector2(240.0, 42.0)
	label.position = center + Vector2(-120.0, -88.0)
	label.z_index = 2
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	label.add_theme_constant_override("outline_size", 5)
	add_child(label)
	_transients.append(label)

	var end_position: Vector2 = label.position + Vector2(0.0, -44.0)
	var tween: Tween = create_tween()
	_label_tweens.append(tween)
	tween.set_parallel(true)
	tween.tween_property(label, "position", end_position, 0.55) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.40).set_delay(0.15)
	tween.finished.connect(_on_label_finished.bind(label, tween))


func _spawn_sparks(center: Vector2, perfect: bool, color: Color) -> void:
	var sparks: CPUParticles2D = CPUParticles2D.new()
	# Configure while stopped, then start once the node is in the tree.
	sparks.emitting = false
	sparks.position = center
	sparks.z_index = 1
	sparks.amount = 18 if perfect else 10
	sparks.lifetime = 0.28 if perfect else 0.22
	sparks.one_shot = true
	sparks.explosiveness = 1.0
	sparks.direction = Vector2.UP
	sparks.spread = 95.0
	sparks.gravity = Vector2(0.0, 260.0)
	sparks.initial_velocity_min = 110.0 if perfect else 70.0
	sparks.initial_velocity_max = 180.0 if perfect else 130.0
	sparks.scale_amount_min = 2.0
	sparks.scale_amount_max = 4.0 if perfect else 3.0
	sparks.color = color
	# With no texture assigned, CPUParticles2D draws small square particles.
	sparks.finished.connect(_free_transient.bind(sparks))
	add_child(sparks)
	_transients.append(sparks)
	sparks.emitting = true


func _on_label_finished(label: Label, tween: Tween) -> void:
	_label_tweens.erase(tween)
	_free_transient(label)


func _free_transient(transient: Node) -> void:
	_transients.erase(transient)
	if is_instance_valid(transient):
		if not transient.is_queued_for_deletion():
			transient.queue_free()
