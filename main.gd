extends Node2D

const ARROW_SCENE = preload("res://arrow.tscn")
const ACTIONS = ["left", "up", "right"]
const LANE_X = [250.0, 400.0, 550.0]
const HIT_Y: float = 500.0
const FALL_SPEED: float = 300.0
const LEAD_TIME: float = 1.85
const PERFECT_WINDOW: float = 0.060
const GOOD_WINDOW: float = 0.150
# Seconds the song keeps playing (fading out) after the last beat.
const END_PAD: float = 1.5


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
		"title": "Neon Laser Horizon / Normal",
		"description": "160 bpm · Normal",
		"stream": preload("res://assets/music/Neon Laser Horizon.mp3"),
		"bpm": 160.0, "first_hit": 2.27, "offset": 0.012,
		"note_count": 64, "beat_step": 1.0, "max_beats": 64,
		"pattern": [0, 1, 2, 0, 2, 0, 2, 0],
		"notes": [
			[2.27, 0], [2.645, 1], [3.02, 2], [3.583, 0], [4.145, 2], [4.52, 0], [4.895, 2], [5.27, 0],
			[5.645, 2], [6.02, 0], [6.395, 2], [6.77, 0], [7.145, 2], [7.52, 1], [7.895, 0], [8.27, 1],
			[8.645, 0], [9.02, 1], [9.395, 2], [9.77, 1], [10.145, 0], [10.52, 1], [10.895, 0], [11.27, 1],
			[11.645, 0], [12.02, 1], [12.395, 2], [12.77, 1], [13.145, 2], [13.52, 1], [13.895, 0], [14.27, 1],
			[14.645, 0], [15.02, 1], [15.395, 2], [15.77, 1], [16.145, 2], [16.52, 1], [17.083, 0], [17.645, 2],
			[18.02, 1], [18.395, 0], [18.77, 1], [19.145, 0], [19.52, 1], [19.895, 2], [20.27, 1], [20.645, 2],
			[21.02, 1], [21.395, 2], [21.77, 1], [22.145, 0], [22.52, 1], [22.895, 0], [23.27, 1], [23.645, 2],
			[24.02, 1], [24.395, 2], [25.145, 0], [25.52, 1], [25.895, 0], [26.27, 1], [26.645, 0], [27.02, 1],
			[27.395, 2], [27.77, 1], [28.145, 2], [28.52, 1], [28.895, 0], [29.27, 1], [29.645, 0], [30.02, 1],
			[30.395, 2], [30.77, 1], [31.145, 2], [31.52, 1], [31.895, 0], [32.27, 1], [32.645, 0], [33.02, 1],
			[33.395, 2], [33.77, 1], [34.145, 0], [34.52, 1], [35.083, 0], [35.645, 2], [36.02, 1], [36.395, 2],
			[36.77, 1], [37.145, 2], [37.52, 1], [37.895, 0], [38.27, 1], [38.645, 0], [39.02, 1], [39.395, 2],
			[39.77, 1], [40.145, 2], [40.52, 1], [40.895, 0], [41.27, 1], [41.645, 2], [42.02, 1], [42.395, 2],
			[42.77, 1], [43.145, 0], [43.52, 1], [43.895, 0], [44.27, 1], [44.645, 0], [45.02, 1], [45.395, 2],
			[45.77, 1], [46.145, 2], [46.52, 1], [46.895, 0], [47.27, 1], [47.645, 2], [48.02, 1], [48.395, 2],
			[48.77, 1], [49.145, 0], [49.52, 1], [49.895, 0], [50.27, 1], [50.645, 0], [51.02, 1], [51.395, 2],
			[51.77, 1], [52.145, 2], [52.52, 1], [52.895, 0], [53.27, 1], [53.645, 0], [54.02, 1], [54.395, 2],
			[54.77, 1], [55.145, 2], [55.52, 1], [55.895, 0], [56.27, 1], [56.645, 0], [57.02, 1], [57.395, 2],
			[57.77, 1], [58.145, 2], [58.52, 2], [59.083, 0], [59.645, 2], [60.02, 1], [60.395, 0], [60.77, 1],
			[61.145, 0], [61.52, 2], [61.895, 0], [62.27, 2], [62.645, 0], [63.02, 2], [63.395, 0], [63.77, 1],
			[64.145, 1], [64.52, 1], [64.895, 2], [65.27, 1], [65.645, 2], [66.02, 2], [66.395, 0], [66.77, 1],
			[67.145, 1], [67.52, 1], [67.895, 0], [68.27, 1], [68.645, 0], [69.02, 0], [69.395, 2], [69.77, 1],
			[70.145, 1], [70.52, 2], [70.895, 0], [71.27, 2], [71.645, 0], [72.02, 1], [72.583, 2], [73.145, 0],
			[73.52, 1], [73.895, 2], [74.27, 1], [74.645, 2], [75.02, 2], [75.395, 0], [75.77, 1], [76.145, 1],
			[76.52, 0], [76.895, 2], [77.27, 0], [77.645, 2], [78.02, 0], [78.395, 2], [78.77, 1], [79.145, 1],
			[79.52, 2], [79.895, 0], [80.27, 2], [80.645, 0], [81.02, 2], [81.395, 0], [81.77, 1], [82.145, 1],
			[82.52, 0], [82.895, 2], [83.27, 0], [83.645, 2], [84.02, 1], [84.583, 0], [85.145, 2], [85.52, 0],
			[85.895, 1], [86.27, 0], [86.833, 1], [87.395, 2], [87.77, 0], [88.145, 2], [88.52, 1], [88.895, 0],
			[89.27, 1], [89.645, 0], [90.02, 0], [90.395, 2], [90.77, 1], [91.145, 1], [91.52, 2], [91.895, 0],
			[92.27, 1], [92.645, 1], [93.02, 0], [93.395, 2], [93.77, 1], [94.145, 1], [94.52, 2], [94.895, 0],
			[95.27, 1], [95.645, 1], [96.02, 1], [96.395, 0], [96.77, 1], [97.145, 2], [97.52, 0], [97.895, 2],
			[98.27, 0], [98.645, 2], [99.02, 1], [99.395, 2], [99.77, 1], [100.145, 2], [100.52, 1], [100.895, 0],
			[101.27, 1], [101.645, 0], [102.02, 0], [102.395, 2], [102.77, 1], [103.145, 1], [103.52, 2], [103.895, 0],
			[104.27, 1], [104.645, 1], [105.02, 0], [105.395, 2], [105.77, 1], [106.145, 1], [106.52, 1], [106.895, 2],
			[107.27, 1], [107.645, 2], [108.02, 0], [108.395, 2], [108.77, 0], [109.145, 2], [109.52, 2], [109.895, 0],
			[110.27, 2], [110.645, 0], [111.02, 2], [111.395, 0], [111.77, 1], [112.145, 1], [112.52, 2], [112.895, 0],
			[113.27, 2], [113.645, 0], [114.02, 0], [114.395, 2], [114.77, 1], [115.145, 1], [115.52, 1], [115.895, 0],
			[116.27, 1], [116.645, 0], [117.02, 2], [117.395, 0], [117.77, 1], [118.145, 1], [118.52, 1], [118.895, 2],
			[119.27, 1], [119.645, 2], [120.02, 1], [120.583, 2], [121.145, 0], [121.52, 0], [121.895, 2], [122.27, 1],
			[122.645, 1], [123.02, 1], [123.395, 0], [123.77, 1], [124.145, 0], [124.52, 2], [124.895, 0], [125.27, 1],
			[125.645, 1], [126.02, 1], [126.395, 2], [126.77, 1], [127.145, 2], [127.52, 0], [127.895, 2], [128.27, 1],
			[128.645, 1], [129.02, 1], [129.395, 0], [129.77, 1], [130.145, 0], [130.52, 2], [130.895, 0], [131.27, 1],
			[131.645, 1], [132.02, 1], [132.395, 2], [132.77, 1], [133.145, 2], [133.52, 1], [134.083, 0], [134.645, 2],
			[135.02, 1], [135.395, 0], [135.77, 1], [136.145, 0], [136.52, 0], [136.895, 2], [137.27, 1], [137.645, 1],
			[138.02, 1], [138.395, 2], [138.77, 1], [139.145, 2], [139.52, 2], [139.895, 0], [140.27, 1], [140.645, 1],
			[141.02, 1], [141.395, 0], [141.77, 1], [142.145, 0], [142.52, 0], [142.895, 2], [143.27, 1], [143.645, 1],
			[144.02, 1], [144.395, 2], [144.77, 1], [145.145, 2], [145.52, 1], [146.083, 2], [146.645, 0], [147.02, 0],
			[147.395, 2], [147.77, 0], [148.145, 2], [148.52, 2], [148.895, 0], [149.27, 1], [149.645, 1], [150.02, 1],
			[150.395, 0], [150.77, 1], [151.145, 0], [151.52, 0], [152.083, 2], [152.645, 0], [153.02, 2], [153.395, 0],
			[153.77, 2], [154.145, 0], [154.52, 0], [154.895, 2], [155.27, 1], [155.645, 1], [156.02, 1], [156.395, 2],
			[156.77, 1], [157.145, 2], [157.52, 2], [158.083, 0], [158.645, 2], [159.395, 0], [159.77, 2], [160.145, 0],
			[160.708, 2], [161.27, 0], [161.645, 1], [162.02, 2], [162.583, 0], [163.145, 2], [163.708, 0], [164.458, 2],
			[164.833, 0], [165.208, 2], [165.958, 0], [166.333, 2], [166.895, 0], [167.27, 1], [167.645, 2], [168.395, 0],
			[168.77, 2], [169.145, 0], [169.52, 1], [169.895, 2], [170.458, 1], [171.395, 0], [171.77, 2]
		]
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
var end_time: float = 0.0
var base_volume_db: float = 0.0


func _ready() -> void:
	base_volume_db = music.volume_db
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
	if level.has("notes"):
		for n in level["notes"]:
			chart.append({"time": float(n[0]), "lane": int(n[1])})
	else:
		var pattern: Array = level["pattern"]
		for i in range(int(level["note_count"])):
			chart.append({
				"time": float(level["first_hit"]) + i * seconds_per_beat * float(level["beat_step"]),
				"lane": int(pattern[i % pattern.size()])
			})

	# Optional "max_beats": the level ends on that beat (counting first_hit as beat 1).
	var last_beat: float = float(chart.back()["time"]) if not chart.is_empty() else 0.0
	if level.has("max_beats"):
		last_beat = float(level["first_hit"]) + (int(level["max_beats"]) - 1) * seconds_per_beat
		while not chart.is_empty() and float(chart.back()["time"]) > last_beat + 0.01:
			chart.pop_back()
	end_time = last_beat + END_PAD


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
	feedback = ""
	front_end.hide()
	receptors.show()
	hud.show()
	start_usec = Time.get_ticks_usec()
	music.volume_db = base_volume_db
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
	# Fade the music out over the last END_PAD seconds.
	if song_time > end_time - END_PAD:
		var fade: float = clampf((end_time - song_time) / END_PAD, 0.001, 1.0)
		music.volume_db = base_volume_db + linear_to_db(fade)
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
	if next_note == chart.size() and notes.is_empty() and song_time >= end_time:
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
	if not running:
		return
	if next_note == chart.size() and notes.is_empty():
		_finish_run("Chart complete")
	else:
		_finish_run("Audio ended early - adjust the song or chart length")
