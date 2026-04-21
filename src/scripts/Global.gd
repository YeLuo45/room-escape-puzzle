extends Node

const LEVEL_ORDER = ["Level1_Bedroom", "Level2_Kitchen", "Level3_Study", "Level4_Basement", "Level5_Lobby"]
const LEVEL_NAMES = {
	"Level1_Bedroom": "卧室",
	"Level2_Kitchen": "厨房",
	"Level3_Study": "书房",
	"Level4_Basement": "地下室",
	"Level5_Lobby": "出口大厅"
}

var current_level: String = "Level1_Bedroom"
var inventory: Array = []
var hints_used: int = 0
var hints_per_level: int = 3
var hints_remaining: int = 3
var selected_item = null
var is_combine_mode: bool = false
var combine_first_item = null
var audio_enabled: bool = true
var music_enabled: bool = true

signal level_changed(level_id: String)
signal inventory_updated()
signal hint_used(remaining: int)
signal item_selected(item)
signal game_solved()

func _ready():
	load_game()

func get_level_display_name(level_id: String) -> String:
	return LEVEL_NAMES.get(level_id, level_id)

func load_level(level_id: String):
	current_level = level_id
	hints_remaining = hints_per_level
	SaveSystem.save_game()
	level_changed.emit(level_id)

func next_level():
	var idx = LEVEL_ORDER.find(current_level)
	if idx >= 0 and idx < LEVEL_ORDER.size() - 1:
		load_level(LEVEL_ORDER[idx + 1])
	else:
		game_solved.emit()

func add_item(item):
	if inventory.size() < 6 and not inventory.has(item):
		inventory.append(item)
		inventory_updated.emit()

func remove_item(item):
	if inventory.has(item):
		inventory.erase(item)
		inventory_updated.emit()

func select_item(item):
	if selected_item == item:
		deselect_item()
		return
	selected_item = item
	item_selected.emit(item)

func deselect_item():
	selected_item = null
	is_combine_mode = false
	combine_first_item = null
	item_selected.emit(null)

func use_hint() -> bool:
	if hints_remaining > 0:
		hints_remaining -= 1
		hints_used += 1
		hint_used.emit(hints_remaining)
		return true
	return false

func has_item(item_id: String) -> bool:
	for item in inventory:
		if item.id == item_id:
			return true
	return false

func reset_level_state():
	hints_remaining = hints_per_level
	selected_item = null
	is_combine_mode = false
	combine_first_item = null
