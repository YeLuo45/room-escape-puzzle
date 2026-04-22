extends Node

# Game state
var current_level = "Level1_Bedroom"
var inventory = []
var hints_used = 0
var audio_enabled = true
var music_enabled = true
var is_paused = false
var selected_item = null
var hints_remaining = 5

# Platform detection
var is_mobile = false
var is_browser = false

signal level_changed(level_id: String)
signal inventory_updated()
signal item_selected(item)
signal hint_used(remaining: int)

var level_names = {
	"Level1_Bedroom": "卧室",
	"Level2_Kitchen": "厨房",
	"Level3_Study": "书房",
	"Level4_Basement": "地下室",
	"Level5_Exit": "出口大厅"
}

func _ready():
	is_mobile = OS.get_name() in ["Android", "iOS"]
	is_browser = OS.get_name() in ["HTML5"]

func get_level_display_name(level_id: String) -> String:
	return level_names.get(level_id, level_id)

func add_item(item):
	if item and "id" in item:
		inventory.append(item)
		inventory_updated.emit()

func remove_item(item):
	var idx = inventory.find(item)
	if idx >= 0:
		inventory.remove_at(idx)
		inventory_updated.emit()
		return true
	return false

func select_item(item):
	selected_item = item
	item_selected.emit(item)

func deselect_item():
	selected_item = null

func has_item(item_id: String) -> bool:
	for item in inventory:
		if item and "id" in item and item.id == item_id:
			return true
	return false

func use_hint():
	if hints_remaining > 0:
		hints_remaining -= 1
		hint_used.emit(hints_remaining)

func next_level():
	var levels = ["Level1_Bedroom", "Level2_Kitchen", "Level3_Study", "Level4_Basement", "Level5_Exit"]
	var idx = levels.find(current_level)
	if idx >= 0 and idx < levels.size() - 1:
		current_level = levels[idx + 1]
		level_changed.emit(current_level)
	else:
		# Game complete
		current_level = "Level1_Bedroom"
		inventory.clear()
		hints_remaining = 5
		hints_used = 0

func restart_level():
	get_tree().reload_current_scene()

func reset_game():
	current_level = "Level1_Bedroom"
	inventory.clear()
	hints_remaining = 5
	hints_used = 0
	selected_item = null
