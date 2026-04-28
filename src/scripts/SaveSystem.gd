extends Node

const SAVE_PATH = "user://save_game.tres"

func save_game():
	var data = {
		"current_level": Global.current_level,
		"inventory_ids": [],
		"hints_used": Global.hints_used,
		"audio_enabled": Global.audio_enabled,
		"music_enabled": Global.music_enabled
	}
	for item in Global.inventory:
		if item and "id" in item:
			data["inventory_ids"].append(item.id)
	
	var save_file = File.open(SAVE_PATH, File.WRITE)
	if save_file == OK:
		save_file.store_line(JSON.print(data))
		save_file.close()

func load_game():
	if not File.file_exists(SAVE_PATH):
		return false
	
	var save_file = File.open(SAVE_PATH, File.READ)
	if save_file != OK:
		return false

	var json_str = save_file.get_line()
	save_file.close()
	
	var json = JSON.new()
	if json.parse(json_str) != OK:
		return false
	
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		return false

	Global.current_level = data.get("current_level", "Level1_Bedroom")
	Global.hints_used = data.get("hints_used", 0)
	Global.audio_enabled = data.get("audio_enabled", true)
	Global.music_enabled = data.get("music_enabled", true)
	
	# Rebuild inventory from IDs
	Global.inventory.clear()
	var inventory_ids = data.get("inventory_ids", [])
	for item_id in inventory_ids:
		var item = ItemDB.get_item(item_id)
		if item:
			Global.inventory.append(item)
	
	return true

func has_save():
	return File.file_exists(SAVE_PATH)

func delete_save():
	if File.file_exists(SAVE_PATH):
		Directory.remove(SAVE_PATH)
