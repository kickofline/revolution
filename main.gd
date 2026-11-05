extends Node2D

const ARROW_SCENE = preload("res://arrow.tscn")
const ACTIONS = ["left", "up", "right"]
const LANE_X = [250.0, 400.0, 550.0]
const HIT_Y: float = 500.0
const FALL_SPEED: float = 300.0
const LEAD_TIME: float = 1.85
const PERFECT_WINDOW: float = 0.060
const GOOD_WINDOW: float = 0.150

# These are short practice charts, not automatically analyzed full songs.
# Level 1 keeps your saved Newer Wave calibration.
# Calibrate the first hit and offset separately for the other songs.
const LEVELS: Array[Dictionary] = [
	{
		"title": "1 - Newer Wave / Warm-up",
		"description": "110 bpm",
		"stream": preload("res://assets/music/Newer Wave.mp3"),
		"bpm": 110.0, "first_hit": 2.0, "offset": -0.25,
		"note_count": 32, "beat_step": 1.0,
		"pattern": [0, 1, 2, 1, 0, 2]
	},
	{
		"title": "2 - Realizer / Groove",
		"description": "125 bpm",
		"stream": preload("res://assets/music/Realizer.mp3"),
		"bpm": 125.0, "first_hit": 2.0, "offset": 0.0,
		"note_count": 48, "beat_step": 1.0,
		"pattern": [0, 2, 1, 0, 1, 2, 0, 2]
	},
	{
		"title": "3 - Neon Laser Horizon / Rush",
		"description": "160 BPM",
		"stream": preload("res://assets/music/Neon Laser Horizon.mp3"),
		"bpm": 160.0, "first_hit": 2.0, "offset": -0.25,
		"note_count": 64, "beat_step": 1,
		"pattern": [0, 1, 2, 1, 2, 0, 2, 1]
	}
]

@onready var hud: Label = $HUD
@onready var music: AudioStreamPlayer = $Music
@onready var receptors: Node2D = $Receptors
@onready var front_end: RhythmFrontEnd = $MenuLayer/FrontEnd
@onready var hit_fx: RhythmFeedback = $Feedback

var chart: Array[Dictionary] = []
var notes: Array[RhythmNote] = []
var active_level: int = -1
var next_note: int = 0
var song_time: float = 0.0
var start_usec: int = 0
var timing_offset: float = 0.0
var running: bool = false
var score: int = 0
var combo: int = 0
var best_combo: int = 0
var misses: int = 0
var perfects: int = 0
var goods: int = 0
var feedback: String = ""


func _ready() -> void:
	music.finished.connect(_on_music_finished)
	front_end.level_selected.connect(_on_level_selected)
	front_end.retry_requested.connect(_start_run)
	front_end.menu_requested.connect(_show_menu)
	front_end.set_levels(LEVELS)
	_show_menu()


func _on_level_selected(index: int) -> void:
	active_level = index
	var level: Dictionary = LEVELS[index]
	music.stream = level["stream"] as AudioStream
	timing_offset = float(level["offset"])
	_build_chart(level)
	_start_run()


func _build_chart(level: Dictionary) -> void:
	chart.clear()
	var seconds_per_beat: float = 60.0 / float(level["bpm"])
	var pattern: Array = level["pattern"]
	for i in range(int(level["note_count"])):
		chart.append({
			"time": float(level["first_hit"]) + i * seconds_per_beat * float(level["beat_step"]),
			"lane": int(pattern[i % pattern.size()])
		})


func _clear_notes() -> void:
	for note in notes:
		note.queue_free()
	notes.clear()


func _show_menu() -> void:
	running = false
	music.stop()
	_clear_notes()
	hit_fx.reset()
	receptors.hide()
	hud.hide()
	active_level = -1
	front_end.show_start()


func _start_run() -> void:
	if active_level < 0:
		return
	running = false
	music.stop()
	_clear_notes()
	hit_fx.reset()
	next_note = 0
	score = 0
	combo = 0
	best_combo = 0
	misses = 0
	perfects = 0
	goods = 0
	song_time = minf(0.0, timing_offset)
	feedback = "Arrow keys to hit - R retries - Esc opens menu"
	front_end.hide()
	receptors.show()
	hud.show()
	start_usec = Time.get_ticks_usec()
	running = true
	music.play()
	_refresh_hud()


func _update_clock() -> void:
	var raw_time: float
	if music.stream != null:
		raw_time = music.get_playback_position()
		raw_time += AudioServer.get_time_since_last_mix()
		raw_time -= AudioServer.get_output_latency()
	else:
		raw_time = (Time.get_ticks_usec() - start_usec) / 1000000.0
	song_time = maxf(song_time, raw_time + timing_offset)


func _process(_delta: float) -> void:
	if not running:
		return
	_update_clock()
	while next_note < chart.size():
		var entry: Dictionary = chart[next_note]
		var hit_time: float = float(entry["time"])
		if hit_time - song_time > LEAD_TIME:
			break
		var note: RhythmNote = ARROW_SCENE.instantiate() as RhythmNote
		add_child(note)
		note.setup(int(entry["lane"]), hit_time)
		notes.append(note)
		next_note += 1

	for i in range(notes.size() - 1, -1, -1):
		var note: RhythmNote = notes[i]
		note.position = Vector2(
			LANE_X[note.lane],
			HIT_Y - (note.hit_time - song_time) * FALL_SPEED
		)
		if song_time - note.hit_time > GOOD_WINDOW:
			notes.remove_at(i)
			hit_fx.play_miss(note.lane)
			note.queue_free()
			misses += 1
			combo = 0
			feedback = "Miss"
			_refresh_hud()
	_check_complete()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("ui_cancel"):
		_show_menu()
		get_viewport().set_input_as_handled()
		return
	if not running:
		return
	if event.is_action_pressed("restart"):
		_start_run()
		get_viewport().set_input_as_handled()
		return
	for lane in range(ACTIONS.size()):
		if event.is_action_pressed(ACTIONS[lane]):
			_judge(lane)
			get_viewport().set_input_as_handled()
			return


func _judge(lane: int) -> void:
	_update_clock()
	var closest: RhythmNote = null
	var closest_distance: float = GOOD_WINDOW + 0.000001
	for note in notes:
		if note.lane != lane:
			continue
		var distance: float = absf(note.hit_time - song_time)
		if distance <= GOOD_WINDOW and distance < closest_distance:
			closest = note
			closest_distance = distance
	if closest == null:
		return

	var perfect: bool = closest_distance <= PERFECT_WINDOW
	if perfect:
		score += 1000
		perfects += 1
		feedback = "Perfect"
	else:
		score += 500
		goods += 1
		feedback = "Good"
	combo += 1
	best_combo = maxi(best_combo, combo)
	hit_fx.play_hit(lane, perfect, combo)
	notes.erase(closest)
	closest.queue_free()
	_refresh_hud()
	_check_complete()


func _refresh_hud() -> void:
	var title: String = String(LEVELS[active_level]["title"])
	hud.text = "%s\nScore: %d   Combo: %d   Best: %d   Misses: %d\n%s" % [
		title, score, combo, best_combo, misses, feedback
	]


func _check_complete() -> void:
	if next_note == chart.size() and notes.is_empty():
		_finish_run("Chart complete")


func _finish_run(status: String) -> void:
	running = false
	music.stop()
	_clear_notes()
	hit_fx.reset()
	receptors.hide()
	hud.hide()
	var title: String = String(LEVELS[active_level]["title"])
	var summary: String = "%s\n%s\nScore: %d\nPerfect: %d   Good: %d   Miss: %d\nBest combo: %d" % [
		title, status, score, perfects, goods, misses, best_combo
	]
	front_end.show_results(summary)


func _on_music_finished() -> void:
	if running:
		_finish_run("Audio ended early - adjust the song or chart length")
