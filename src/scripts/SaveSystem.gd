extends Node

const SAVE_PATH = "user://save_game.tres"

class SaveData extends Resource:
	var current_level: String
	var inventory_ids: Array[String]
	var hints_used: int
	var audio_enabled: bool
	var music_enabled: bool

func save_game():
	var data = SaveData.new()
	data.current_level = Global.current_level
	data.inventory_ids = []
	for item in Global.inventory:
		if item and item.id:
			data.inventory_ids.append(item.id)
	data.hints_used = Global.hints_used
	data.audio_enabled = Global.audio_enabled
	data.music_enabled = Global.music_enabled
	
	var err = ResourceSaver.save(data, SAVE_PATH)
	if err != OK:
		print("Save error: ", err)

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	
	var data = ResourceLoader.load(SAVE_PATH)
	if data == null or not data is SaveData:
		return false
	
	Global.current_level = data.current_level
	Global.hints_used = data.hints_used
	Global.audio_enabled = data.audio_enabled
	Global.music_enabled = data.music_enabled
	
	# Rebuild inventory from IDs (items need to be re-fetched from ItemDB)
	Global.inventory.clear()
	for item_id in data.inventory_ids:
		var item = ItemDB.get_item(item_id)
		if item:
			Global.inventory.append(item)
	
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
