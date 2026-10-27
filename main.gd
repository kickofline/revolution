extends Node2D

const ARROW_SCENE = preload("res://arrow.tscn")
const ACTIONS = ["left", "up", "right"]
const LANE_X = [250.0, 400.0, 550.0]
const HIT_Y: float = 500.0
const FALL_SPEED: float = 300.0
const LEAD_TIME: float = 1.8
const PERFECT_WINDOW: float = 0.060
const GOOD_WINDOW: float = 0.150

# Practice-chart settings. Match these to your music in step 8.
@export var bpm: float = 120.0
@export var first_hit_time: float = 2.0
# Positive values advance the chart relative to the audio.
@export var timing_offset: float = 0.0

@onready var hud: Label = $HUD
@onready var music: AudioStreamPlayer = $Music

var chart: Array[Dictionary] = []
var notes: Array[RhythmNote] = []
var next_note: int = 0
var song_time: float = 0.0
var start_usec: int = 0
var running: bool = false
var score: int = 0
var combo: int = 0
var best_combo: int = 0
var misses: int = 0
var feedback: String = ""


func _ready() -> void:
	music.finished.connect(_on_music_finished)
	_build_chart()
	_start_run()


func _build_chart() -> void:
	chart.clear()
	var seconds_per_beat: float = 60.0 / maxf(bpm, 1.0)
	var pattern = [0, 1, 2, 1, 0, 2]
	for i in range(32):
		chart.append({
			"time": first_hit_time + i * seconds_per_beat,
			"lane": pattern[i % pattern.size()]
		})


func _start_run() -> void:
	music.stop()
	for note in notes:
		note.queue_free()
	notes.clear()
	next_note = 0
	score = 0
	combo = 0
	best_combo = 0
	misses = 0
	song_time = 0.0
	feedback = "go"
	start_usec = Time.get_ticks_usec()
	running = true
	if music.stream != null:
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
	# Audio timing estimates can move slightly backward between frames.
	song_time = maxf(song_time, raw_time + timing_offset)


func _process(_delta: float) -> void:
	if not running:
		return
	_update_clock()

	# Spawn every note whose approach time has started.
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

	# Iterate backward so removing a miss does not skip another note.
	for i in range(notes.size() - 1, -1, -1):
		var note: RhythmNote = notes[i]
		note.position = Vector2(
			LANE_X[note.lane],
			HIT_Y - (note.hit_time - song_time) * FALL_SPEED
		)
		if song_time - note.hit_time > GOOD_WINDOW:
			notes.remove_at(i)
			note.queue_free()
			misses += 1
			combo = 0
			feedback = "Miss"
			_refresh_hud()

	if next_note == chart.size() and notes.is_empty():
		_finish_run("Press R to restart.")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("restart_song"):
		_start_run()
		get_viewport().set_input_as_handled()
		return
	if not running:
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

	# Empty presses do not score or break combo in this version.
	if closest == null:
		return

	if closest_distance <= PERFECT_WINDOW:
		score += 10000000
		feedback = "Perfect"
	else:
		score += 500
		feedback = "Good"
	combo += 1
	best_combo = maxi(best_combo, combo)
	notes.erase(closest)
	closest.queue_free()
	_refresh_hud()


func _refresh_hud() -> void:
	hud.text = "Score: %d   Combo: %d   Best: %d   Misses: %d\n%s" % [
		score, combo, best_combo, misses, feedback
	]


func _finish_run(message: String) -> void:
	running = false
	music.stop()
	feedback = message
	_refresh_hud()


func _on_music_finished() -> void:
	if running:
		_finish_run("Audio ended before the chart cleared. Check its length; R restarts.")
