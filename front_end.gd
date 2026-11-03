class_name RhythmFrontEnd
extends Control

signal level_selected(index: int)
signal retry_requested()
signal menu_requested()

@onready var start_panel: PanelContainer = $StartPanel
@onready var level_panel: PanelContainer = $LevelPanel
@onready var results_panel: PanelContainer = $ResultsPanel

@onready var start_play_button: Button = $StartPanel/Content/PlayButton
@onready var level_picker: OptionButton = $LevelPanel/Content/LevelPicker
@onready var level_description: Label = $LevelPanel/Content/Description
@onready var level_play_button: Button = $LevelPanel/Content/PlayButton
@onready var level_back_button: Button = $LevelPanel/Content/BackButton
@onready var results_summary: Label = $ResultsPanel/Content/Summary
@onready var retry_button: Button = $ResultsPanel/Content/RetryButton
@onready var levels_button: Button = $ResultsPanel/Content/LevelsButton
@onready var menu_button: Button = $ResultsPanel/Content/MenuButton

var _levels: Array[Dictionary] = []
var _selected_index: int = -1


func _ready() -> void:
	start_play_button.pressed.connect(show_levels)
	level_back_button.pressed.connect(show_start)
	level_picker.item_selected.connect(_on_level_picked)
	level_play_button.pressed.connect(_on_play_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	levels_button.pressed.connect(show_levels)
	menu_button.pressed.connect(_on_menu_pressed)
	show_start()


func set_levels(levels: Array[Dictionary]) -> void:
	# Main calls this after this node has entered the scene and is ready.
	# Remember the selection before rebuilding the picker.
	var previous_index: int = _selected_index
	_levels = levels
	level_picker.clear()

	for index in range(_levels.size()):
		var level: Dictionary = _levels[index]
		var title: String = str(level.get("title", "Level %d" % (index + 1)))
		level_picker.add_item(title)

	var has_levels: bool = not _levels.is_empty()
	level_picker.disabled = not has_levels
	level_play_button.disabled = not has_levels

	if not has_levels:
		_selected_index = -1
		level_description.text = "no levels"
		return

	# Preserve the previous index if it still exists; otherwise choose the first.
	if previous_index >= 0 and previous_index < _levels.size():
		_selected_index = previous_index
	else:
		_selected_index = 0
	level_picker.select(_selected_index)
	_update_description()


func show_start() -> void:
	show()
	start_panel.show()
	level_panel.hide()
	results_panel.hide()
	start_play_button.grab_focus()


func show_levels() -> void:
	show()
	start_panel.hide()
	level_panel.show()
	results_panel.hide()
	_update_description()
	if _levels.is_empty():
		level_back_button.grab_focus()
	else:
		level_picker.grab_focus()


func show_results(summary: String) -> void:
	results_summary.text = summary
	show()
	start_panel.hide()
	level_panel.hide()
	results_panel.show()
	retry_button.grab_focus()


func _on_level_picked(index: int) -> void:
	if index < 0 or index >= _levels.size():
		return
	_selected_index = index
	_update_description()


func _update_description() -> void:
	if _selected_index < 0 or _selected_index >= _levels.size():
		level_description.text = "no levels"
		return
	var level: Dictionary = _levels[_selected_index]
	level_description.text = str(level.get("description", ""))


func _on_play_pressed() -> void:
	if _selected_index < 0 or _selected_index >= _levels.size():
		return
	level_selected.emit(_selected_index)


func _on_retry_pressed() -> void:
	retry_requested.emit()


func _on_menu_pressed() -> void:
	menu_requested.emit()
